class DiagnosticsController < ApplicationController

    def index
        @diseases = Disease.all
    end

end