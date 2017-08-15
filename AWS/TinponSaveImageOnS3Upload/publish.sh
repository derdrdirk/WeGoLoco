rm ../tinponSaveImageOnS3Upload.zip
zip -r ../tinponSaveImageOnS3Upload.zip *
cd ..
aws lambda update-function-code --function-name TinponSaveImageOnS3Upload --zip-file fileb://tinponSaveImage.zip
