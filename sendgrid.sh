#!/bin/bash
# Get the arguments
while getopts t:c:s:o:k:n:e: flag
do
    case "${flag}" in
        t) to=${OPTARG};;
        c) cc=${OPTARG};;
        s) subject=${OPTARG};;
        o) body=${OPTARG};;
        k) apikey=${OPTARG};;
        n) fromname=${OPTARG};;
        e) fromemail=${OPTARG};;
    esac
done
# Start building the JSON
sendGridJson="{\"personalizations\": [{";
# Convert the String to Array, with the delimiter as ";"
IFS='; ' read -r -a to_array <<< "$to"
IFS='; ' read -r -a cc_array <<< "$cc"
if [ ${#to_array[@]} != 0 ] 
then
 sendGridJson="${sendGridJson} \"to\": ["
 
 for email in "${to_array[@]}"
 do
     sendGridJson="${sendGridJson} {\"email\": \"$email\"},"
 done
 sendGridJson=`echo ${sendGridJson} | sed 's/.$//'`
 sendGridJson="${sendGridJson} ],"
 if [ ${#cc_array[@]} == 0 ]
 # if [ ${#cc_array[@]} == 0 ] && [ ${#bcc_array[@]} == 0 ]  
 then
  sendGridJson=`echo ${sendGridJson} | sed 's/.$//'`
 fi
fi
if [ ${#cc_array[@]} != 0 ] 
then
 sendGridJson="${sendGridJson} \"cc\": ["
 
 for email in "${cc_array[@]}"
 do
     sendGridJson="${sendGridJson} {\"email\": \"$email\"},"
 done
 sendGridJson=`echo ${sendGridJson} | sed 's/.$//'`
 sendGridJson="${sendGridJson} ],"
 # if [ ${#bcc_array[@]} == 0 ] 
 # then
 #  sendGridJson=`echo ${sendGridJson} | sed 's/.$//'`
 # fi
fi
sendGridJson="${sendGridJson} }],\"from\": {\"email\": \"${fromemail}\",\"name\": \"${fromname}\"},\"subject\":\"${subject}\",\"content\": [{\"type\": \"text/html\",\"value\": \"${body}\"}],"
sendGridJson="${sendGridJson} }"
# Generate a Random File to hold the POST data
tfile=$(mktemp /tmp/sendgrid.XXXXXXXXX)
echo $sendGridJson > $tfile
# Send the HTTP request to SendGrid
curl -X "POST" "https://api.sendgrid.com/v3/mail/send" \
    -H "Authorization: Bearer $apikey" \
    -H "Content-Type: application/json" \
    -d @$tfile