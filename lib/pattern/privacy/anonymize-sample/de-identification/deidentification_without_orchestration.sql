update uniform_resource_investigator 
set email = anonymize_email(email);

update uniform_resource_author 
set email = anonymize_email(email);

update uniform_resource_participant
set age = generalize_age(CAST(age AS INTEGER));