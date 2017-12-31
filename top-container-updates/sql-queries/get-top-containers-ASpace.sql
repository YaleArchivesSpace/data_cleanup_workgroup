select concat('/repositories/', repository.id, '/top_containers/', top_container.id) as 'tc_uri_fragment'
, top_container.barcode
, top_container.indicator
, top_container.type_id as 'top_container_type_id'
, ev.value as 'container_type'
, cp.name as 'container_profile'
, location.title as 'location_name'
, location.id as 'location_id'
, ud.string_2 as 'bib_id'
, resource.title as 'collection'
, resource.ead_id
, repository.name as 'repository_name'
from top_container
join top_container_link_rlshp on top_container.id = top_container_link_rlshp.top_container_id
join sub_container on top_container_link_rlshp.sub_container_id = sub_container.id
join instance on sub_container.instance_id = instance.id
join archival_object on instance.archival_object_id = archival_object.id
join resource on archival_object.root_record_id = resource.id
join user_defined ud on resource.id = ud.resource_id
join repository on resource.repo_id = repository.id
left join enumeration_value ev on ev.id = top_container.type_id
left join top_container_profile_rlshp cpr on cpr.top_container_id = top_container.id
left join container_profile cp on cpr.container_profile_id = cp.id 
left join top_container_housed_at_rlshp tclr on tclr.top_container_id = top_container.id
left join location on tclr.location_id = location.id

where ud.string_2 is not null

group by top_container.id
order by resource.ead_id
;