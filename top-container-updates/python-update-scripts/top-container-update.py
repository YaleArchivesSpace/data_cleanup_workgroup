"""Script to update top container records in ArchivesSpace based on values in a csv input file.
still need to move all of the login and logging settings to configuration files"""
import getpass, requests, json, csv, datetime, logging

 
def login(api_url):
    username = getpass.getuser()
    check_username = input('Is your username ' + username + '?: ')
    if check_username.lower() not in ('y', 'yes', 'yep', 'you know it'):
        username = input('Please enter ArchivesSpace username:  ')
    password = getpass.getpass(prompt=username + ', please enter your ArchivesSpace Password: ', stream=None)
    auth = requests.post(api_url+'/users/'+username+'/login?password='+password).json()
    #if session object is returned then the login was successful; if not it failed.
    if 'session' in auth:
        session = auth["session"]
        authorization_token = {'X-ArchivesSpace-Session':session, 'Content_Type':'application/json'}
        print('Login successful!')
        return (authorization_token)
    else:
        print('Ooops! Try logging in again.')
        return
 
def open_csv():
    '''This function opens a csv file in DictReader mode'''
    input_csv = input('Please enter path to CSV: ')
    file = open(input_csv, 'r', encoding='utf-8')
    return csv.DictReader(file)
 
def get_container_profile_URIs(api_url, headers):
    container_profiles = []
    print('Retrieving container profile data. This may take a moment')
    id_list = requests.get(api_url + '/container_profiles?all_ids=True', headers=authorization_token).json()
    for id in id_list:
        profile_dict = {}
        id_json = requests.get(api_url + '/container_profiles/' + str(id), headers=authorization_token).json()
        for key, value in id_json.items():
             if key == 'name':
                 profile_dict['name'] = value
             if key == 'uri':
                 profile_dict['uri'] = value
             container_profiles.append(profile_dict)
    print('Containers retrieved!')
    return [container_profiles]
     
def update_top_containers(api_url, headers, container_locations=None):
    csv = open_csv()
    for row in csv:
        try:
            record_uri = row['top-container-URI']
            record_json = requests.get(api_url + record_uri, headers=authorization_token).json()
            for key, value in row.items():
                # use the start_date value when creating a new location association; if a start_date is not present, default to today's date
                location_date_to_post = value if (key == 'start_date' and value != '') else str(datetime.date.today())
                
                # check to see if the container_locations list is empty, since ASpace adds that key even if there are no locations assigned.
                # i don't want to check for the empty array like this, but when i tried other methods, it always evaluated to True.  so, going with len() for now
                if len(record_json['container_locations']) == 0 and key == 'aspace-location-URI-to-post':
                    record_json['container_locations'].append({'start_date':location_date_to_post, 'ref':value, 'status':'current'})
                else:
                    # this next bit is all that's needed to update existing location information
                    for member in record_json['container_locations']:
                        if key == 'aspace-location-URI-to-post':
                            member['ref'] = value
                        if key == 'location_start_date' and value != '':
                            member['start_date'] = value

           
                '''
                #Look up container profile name and add uri if found
                if key == 'container_profile':
                    for keyval in cp_list:
                        if value in keyval.values():
                            record_json['container_profile'] = {'ref': keyval.get('uri')}
                '''

                if key == 'voyager-barcode':
                    record_json['barcode'] = value
                    
            record_data = json.dumps(record_json)
            record_update = requests.post(api_url + record_uri, headers=authorization_token, data=record_data).json()
            print(record_update)
            logging.info('%s successfully updated', record_uri)
        except:
            print('Skipping invalid row')
            logging.warning('Skipping invalid row for %s', record_uri)
            continue

def main():
    logging.info('Started')
    '''i'm not updating container_profiles in this first pass, so this section has been removed from the script for now'''
    # container_profiles = get_container_profile_URIs(api_url, authorization_token)
    update_top_containers(api_url, authorization_token)
    logging.info('Finished') 


if __name__ == '__main__':
    logging.basicConfig(filename='container-updates.log', level=logging.INFO, format='%(asctime)s %(message)s')
    logging.getLogger("requests").setLevel(logging.WARNING)
    api_url = input('Please enter the ArchivesSpace API URL: ')
    authorization_token = login(api_url)
    main()

