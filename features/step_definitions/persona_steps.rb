Given /^personas existing$/ do
  Persona.create_all
end

Given /^I am "([^"]*)"$/ do |persona_name|
  step "I am logged in as '%s' with password 'password'" % persona_name.downcase
end

Angenommen /^man ist "([^"]*)"$/ do |persona_name|
  step 'I am "%s"' % persona_name
end

Angenommen /^Personas existieren$/ do
  step 'personas existing'
end