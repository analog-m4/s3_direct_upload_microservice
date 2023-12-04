require 'aws-sdk-s3'

class UploadedFilesController < ApplicationController
    def create_presigned_url
        s3 = Aws::S3::Resource.new(region: 'us-east-1')
        obj = s3.bucket('analogcapstonefiles').object(params[:file_name])
        url = obj.presigned_url(:put, acl: 'public-read')

        render json: { presigned_url: url }, status: 200
    end

    def upload_complete
        uploaded_file = UploadedFile.create(
            file_name: params[:file_name],
            s3_key: params[:s3_key]
        )

        if uploaded_file.persisted?
            render json: { status: 'File uploaded sucessfully.' }, status: 201
        else
            render json: { status: 'Failed to upload file', errors: uploaded_files.errors.full_messages }, status: 400
        end
    end
end
