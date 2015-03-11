### README

#### Getting started

1. Start the bridge to the desired Protege OWL file. This can be done by calling `rails runner scripts/protege-bridge.rb owl/ontology.owl` from the base directory with the sample OWL ontology.
2. Start the Rails server by calling `rails s`
3. Initialize the ngrok proxy by invoking `./bin/ngrok -subdomain="cc6a7a8e5b" 3000`
