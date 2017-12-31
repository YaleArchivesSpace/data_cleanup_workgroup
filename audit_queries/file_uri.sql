SELECT DISTINCT file_version.digital_object_id,
	digital_object.repo_id,
	file_version.file_uri
FROM file_version LEFT JOIN digital_object ON file_version.digital_object_id = digital_object.id
WHERE file_version.file_uri LIKE '%http%' AND 
	file_version.file_uri NOT LIKE '%preservica.library.yale.edu%';