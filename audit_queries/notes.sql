SELECT DISTINCT note.resource_id,
	resource.repo_id,
	note.archival_object_id,
    archival_object.repo_id,
	CONVERT(note.notes USING utf8)
FROM (note LEFT JOIN resource ON note.resource_id = resource.id)
	LEFT JOIN archival_object ON note.archival_object_id = archival_object.id
WHERE CONVERT(note.notes USING utf8) LIKE '%href=%';

