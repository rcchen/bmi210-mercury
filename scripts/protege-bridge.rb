# Creates a watcher process to import changes from Protege into the server
# Usage: rails runner protege-bridge.rb <filename>
# Filename must be an OWL/XML file created by Protege

require "filewatcher"
require "nokogiri"

# Get command line argument as a constant
OWL_FILE = ARGV[0]

# Responsible for synchronizing data into the database
def synchronizeDatabase

    # Clean up the database
    Disease.delete_all
    Symptom.delete_all
    Factor.delete_all
    DiseaseSymptom.delete_all
    DiseaseFactor.delete_all

    # Load file into a Nokogiri object for parsing
    f = File.open(OWL_FILE)
    doc = Nokogiri::XML(f)

    # First register all of the subclasses into the system
    subclasses = doc.css("SubClassOf")
    numRegistered = 0
    numLastRegistered = -1
    while (numLastRegistered < numRegistered)
        numLastRegistered = numRegistered
        subclasses.each do |subclass|

            classes = subclass.css("Class")
            if classes.length == 2
                first = classes[0].attr("IRI")[1..-1]
                second = classes[1].attr("IRI")[1..-1]
            end

            # If the subclass registers an ObjectProperty, only register something if the respective classes exist
            objectProperties = subclass.css("ObjectAllValuesFrom")
            if objectProperties.length > 0
                # The first should be a disease, the second could be a symptom or risk factor
                disease = Disease.find_by_name(first)
                symptom = Symptom.find_by_name(second)
                factor = Factor.find_by_name(second)
                if disease
                    if symptom and DiseaseSymptom.where(:disease_id => disease.id, :symptom_id => symptom.id).empty?
                        DiseaseSymptom.create(:disease_id => disease.id, :symptom_id => symptom.id)
                        numRegistered += 1
                    elsif factor and DiseaseFactor.where(:disease_id => disease.id, :factor_id => factor.id).empty?
                        DiseaseFactor.create(:disease_id => disease.id, :factor_id => factor.id)
                        numRegistered += 1
                    end
                end
                next
            end

            # If there are two Class child objects, then the first is a subclass of the second
            child = first
            parent = second

            # Checks for existence
            has_created = false
            if ["Disease", "Symptom", "Risk_factor"].include?(parent)
                # The first three cases are for parents, the next three are for nested classes
                baseParams = {:parent => nil, :name => child}
                nestedParams = {:parent => parent, :name => child}
                case parent
                when "Disease"
                    has_created = Disease.where(baseParams).exists?
                when "Symptom"
                    has_created = Symptom.where(baseParams).exists?
                when "Risk_factor"
                    has_created = Factor.where(baseParams).exists?
                else
                    has_created_disease = Disease.where(nestedParams).exists?
                    has_created_symptom = Symptom.where(nestedParams).exists?
                    has_created_factor = Factor.where(nestedParams).exists?
                end
                has_created = (has_created || has_created_disease || has_created_symptom || has_created_factor)
            end

            # We have three registered Class objects
            if !has_created
                case parent
                when "Disease"
                    Disease.create(:name => child)
                    numRegistered += 1
                when "Symptom"
                    Symptom.create(:name => child)
                    numRegistered += 1
                when "Risk_factor"
                    Factor.create(:name => child)
                    numRegistered += 1
                else
                    # Checks to see if its parent is a disease
                    potentialDisease = Disease.find_by_name(parent)
                    if potentialDisease and potentialDisease.name != child
                        if !Disease.find_by_name(child)
                            Disease.create(:name => child, :parent_id => potentialDisease.id)
                            numRegistered += 1
                        end
                    end
                    # Checks to see if its parent is a symptom
                    potentialSymptom = Symptom.find_by_name(parent)
                    if potentialSymptom and potentialSymptom.name != child
                        if !Symptom.find_by_name(child)
                            Symptom.create(:name => child, :parent_id => potentialSymptom.id)
                            numRegistered += 1
                        end
                    end
                    # Checks to see if its parent is a risk factor
                    potentialFactor = Factor.find_by_name(parent)
                    if potentialFactor and potentialFactor.name != child
                        if !Factor.find_by_name(child)
                            Factor.create(:name => child, :parent_id => potentialFactor.id)
                            numRegistered += 1
                        end
                    end
                end
            end
        end
    end

    puts "Diseases: #{Disease.all.count}\tSymptoms: #{Symptom.all.count}\tRisk_factors: #{Factor.all.count}\n"

    # Clean-up
    f.close
end

# Force a synchronization on startup
synchronizeDatabase()

# Creates a process that polls the filesystem to listen for subsequent changes
FileWatcher.new(OWL_FILE).watch do |filename, event|
    if (event == :changed)
        puts "File updated: " + filename
        synchronizeDatabase()
    end
end

