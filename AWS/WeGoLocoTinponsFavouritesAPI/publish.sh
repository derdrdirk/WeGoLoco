rm ../tinponsFavouritesAPI.zip
zip -r ../tinponsFavouritesAPI.zip *
cd ..
aws lambda update-function-code --function-name WeGoLocoTinponsFavouritesAPI --zip-file fileb://tinponsFavouritesAPI.zip
cd WeGoLocoTinponsFavouritesAPI
