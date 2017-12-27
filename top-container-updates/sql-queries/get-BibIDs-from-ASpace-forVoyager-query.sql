select string_2
from user_defined ud
join resource on resource.id = ud.resource_id
join repository on resource.repo_id = repository.id
where resource_id is not null and string_2 is not null;