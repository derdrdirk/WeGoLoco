rm ../tinponsSwipedAPI.zip
zip -r ../tinponsSwipedAPI.zip *
cd ..
aws lambda update-function-code --function-name WeGoLocoTinponsSwipedAPI --zip-file fileb://tinponsSwipedAPI.zip
cd WeGoLocoTinponsSwipedAPI
