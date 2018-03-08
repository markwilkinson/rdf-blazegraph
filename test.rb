
gem 'rdf', '=2.0.2'
gem 'rdf-vocab', '=2.0.2'
gem 'sparql-client', '=2.0.2'
gem 'sparql', "=2.0"
gem 'rdf-aggregate-repo', '=2.2.0'
gem 'ebnf', '=1.1.0'
gem 'sxp', '=1.0.0'
gem 'rdf-xsd', '=2.0.0'
#gem 'rdf/blazegraph', '=0.0.3'

require 'rdf'
require 'rdf/vocab'
load 'lib/rdf/blazegraph/repository.rb'
load 'lib/rdf/blazegraph/rest_client.rb'
load 'lib/rdf/blazegraph.rb'
require 'sparql'

#require 'rdf/blazegraph'
require 'active/triples'

# as an RDF::Repository
repo = RDF::Blazegraph::Repository.new(uri: 'http://localhost:9999/blazegraph/namespace/kb/sparql')
repo << RDF::Statement(RDF::URI('http://example.org/#stormy'), RDF::Vocab::FOAF.name, 'Stormy')
repo.count # => 1

# with REST interface
#nano = RDF::Blazegraph::RestClient.new('http://localhost:9999/bigdata/sparql')
#nano.get_statements.each { |s| puts s.inspect }




ActiveTriples::Repositories.add_repository :default, repo
#ActiveTriples::Repositories.add_repository :people, RDF::Repository.new


class Person
  include  ActiveTriples::RDFSource

  configure type:       RDF::Vocab::FOAF.Person,
            base_uri:   'http://example.org/people#',
            repository: :default
  property :name, predicate: RDF::Vocab::FOAF.name


# Find a person
  def Person.find(args = {})
    id = args.fetch(:id)
    id = Person.configuration[:base_uri] + id
 
    query = SPARQL.parse("SELECT * where {<#{id}> ?p ?o}")  # this should be a DESCRIBE, I guess...
    repo = ActiveTriples::Repositories.repositories[Person.configuration[:repository]]
    solutions = repo.query(query)
 
    if solutions.any?
       p = Person.new(id)
    else
      return nil
    end    
    return p
  end

end


class Thing
  include  ActiveTriples::RDFSource

  configure type:       RDF::OWL.Thing,
            base_uri:   'http://example.org/things#',
            repository: :default

  property :title,       predicate: RDF::Vocab::DC.title
  property :description, predicate: RDF::Vocab::DC.description
  property :creator,     predicate: RDF::Vocab::DC.creator, class_name: 'Person'
end


#painting         = Thing.new('Painting2')
#painting.title   = 'La Vie'
#painting.creator = Person.new('P_Picasso')
#
#painting.persisted? # => false
#
#ActiveTriples::Repositories.repositories[:default].dump :ntriples
#
#painting.creator.first.name = 'Picasso'
#painting.persist!
#
#puts ActiveTriples::Repositories.repositories[:default].dump :ntriples
#
#
#person2 = Person.find(id: 'P_Picasso')
#puts person2.name.first.value

aaa = Thing.new('aaa')
bbb = Person.new('bbb')
bbb.name="startinghere"
bbb.persist!

puts aaa.creator

aaa.creator = bbb

aaa.creator.first.name = "Persistme"
puts bbb.name.first
aaa.persist!  # not in database!
aaa.creator.first.persist!  # still not in database!

bbb.persist!  # Now in database


