#!/usr/bin/python

# Use: Extract and check links in note.notes. Write retrieved URL and HTTP response codes to outfile. Retrieved url is empty string if connection failed.

# Update
datafile = 'notes_prod_20171127.tsv'
outfile = 'notes_audit_prod_20171127.tsv'

import json
import re
from check_url import *

href = re.compile(r'href=\"[^"]*\"')

# Read urls in notes into data.
data = []
with open(datafile, 'r') as f:
    headers = f.next().strip('\r\n').split('\t')
    for line in f:
        row = line.strip('\r\n').split('\t')
        r = row[:4]
        s = ''
        note = json.loads(row[4].strip('\r\n'))
        keys = note.keys()
        if 'content' in keys:
            content = note['content']
            if isinstance(content, basestring):
                s += content
            else:
                for c in content:
                    s += c
        if 'items' in keys:
            for item in note['items']:
                if isinstance(item, basestring):
                    s += item
                else:
                    for v in item['value']:
                        s += v
                    for l in item['label']:
                        s += l
        if 'subnotes' in keys:
            for subnote in note['subnotes']:
                subnote_keys = subnote.keys()
                if 'content' in subnote_keys:
                    content = subnote['content']
                    if isinstance(content, basestring):
                        s += content
                    else:
                        for c in content:
                            s += c
                if 'items' in subnote_keys:
                    for item in subnote['items']:
                        if isinstance(item, basestring):
                            s += item
                        else:
                            for v in item['value']:
                                s += v
                            for l in item['label']:
                                s += l
        for match in href.finditer(s):
            d = r + [match.group()[6:-1]]
            data.append(d)

# Check urls. Write output.
out = open(outfile, 'w')
headers += ['retrieved_url', 'http_response_code']
output = '\t'.join(headers) + '\n'
out.write(output)
for row in data:
    response = check_url(row[4], 5)
    row += response
    output = '\t'.join(map(lambda x: str(x), row)) + '\n'
    out.write(output)
out.close()













