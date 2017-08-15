rm ../tinponsAPI.zip
zip -r ../tinponsAPI.zip *
cd ..
aws lambda update-function-code --function-name WeGoLocoTinponsAPI --zip-file fileb://tinponsAPI.zip
cd WeGoLocoTinponsAPI
