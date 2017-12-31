"""Script to update top container records in ArchivesSpace based on values in a csv input file.
still need to move all of the login and logging settings to configuration files
questions:
any way to get an accurate location start date from GFA?
if not, should the location start date include a location note, mentioning that the value supplied is based on the date when the script was run?
what else???
"""
import getpass, requests, json, csv, datetime, sys, logging

def login(api_url):
    username = getpass.getuser()
    check_username = input('Is your username ' + username + '?: ')
    if check_username.lower() not in ('y', 'yes', 'yep', 'you know it'):
        username = input('Please enter ArchivesSpace username:  ')
    password = getpass.getpass(prompt=username + ', please enter your ArchivesSpace Password: ', stream=None)
    auth_request = requests.post(api_url+'/users/'+username+'/login?password='+password).json()
    if 'session' in auth_request:
        session = auth_request['session']
        authorization_token = {'X-ArchivesSpace-Session':session, 'Content_Type':'application/json'}
        print('Login successful!')
        return (authorization_token)
    else:
        print('Ooops! Try logging in again.')
        sys.exit()
 
def open_csv():
    '''This function opens a csv file in DictReader mode'''
    input_csv = input('Please enter path to CSV: ')
    file = open(input_csv, 'r', encoding='utf-8')
    return csv.DictReader(file)
      
def update_top_containers(api_url, headers, container_locations=None):
    csv = open_csv()
    default_date = str(datetime.date.today())
    for row in csv:
        try:
            record_uri = row.get("top-container-URI")
            new_barcode = row.get("voyager-barcode")
            container_location = row.get("aspace-location-URI-to-post")
            location_date_to_post = row.get("start_date", default_date)
            if location_date_to_post == '':
                location_date_to_post = default_date
            
            record_json = requests.get(api_url + record_uri, headers=authorization_token).json()
            logging.info(record_uri + ' Original JSON: ' + json.dumps(record_json))
            # check to see if the container_locations list is empty.
            if not record_json["container_locations"] and container_location != '':
                record_json["container_locations"].append({'start_date':location_date_to_post, 'ref':container_location, 'status':'current'})
            else:
            # this next bit is all that's needed to update existing location information, and for now I'm assuming that there's only 1 location.
                for location in record_json["container_locations"]:
                    current_location = location.get('ref')
                    if container_location != '':
                        location['ref'] = container_location
                    if container_location != current_location:
                        location['start_date'] = location_date_to_post

            if new_barcode:
                record_json['barcode'] = new_barcode
                
            record_data = json.dumps(record_json)
            record_update = requests.post(api_url + record_uri, headers=authorization_token, data=record_data).json()
            print(record_update)
            logging.info('%s successfully updated', record_uri)
            logging.info(record_uri + ' Updated JSON: ' + record_data)
            logging.info('\n')
        
        except Exception as ex:
            print('Skipping invalid row')
            logging.warning('Skipping invalid row for %s. Exception: %s\n', record_uri, ex)
            continue

def main():
    logging.info('Started updates in %s', api_url)
    update_top_containers(api_url, authorization_token)
    logging.info('Finished updates in %s', api_url)
    input("Press enter to exit... ")

if __name__ == '__main__':
    logging.basicConfig(filename='container-updates.log', level=logging.INFO, format='%(asctime)s %(message)s')
    logging.getLogger("requests").setLevel(logging.WARNING)
    api_url = input('Please enter the ArchivesSpace API URL: ')
    authorization_token = login(api_url)
    main()
