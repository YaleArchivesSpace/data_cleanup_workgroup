SELECT DISTINCT digital_object.id, 
	digital_object.repo_id,
	digital_object.digital_object_id
FROM digital_object
WHERE digital_object.digital_object_id LIKE '%http%';