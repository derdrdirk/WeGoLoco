rm ../tinponsImagesAPI.zip
zip -r ../tinponsImagesAPI.zip *
cd ..
aws lambda update-function-code --function-name WeGoLocoTinponsImagesAPI --zip-file fileb://tinponsImagesAPI.zip
cd WeGoLocoTinponsImagesAPI
