require 'aws-sdk-s3'

class UploadedFilesController < ApplicationController
    before_action :set_circuit_breaker

    def create_presigned_url
        s3 = Aws::S3::Resource.new(region: 'us-east-1')
        obj = s3.bucket('analogcapstonefiles').object(params[:file_name])
        url = obj.presigned_url(:put)
        render json: { presigned_url: url }, status: 200
    end

    def upload_complete
        uploaded_file = UploadedFile.create(
            file_name: params[:file_name]
        )

        if uploaded_file.persisted?
            render json: { status: 'File uploaded sucessfully.' }, status: 201
        else
            render json: { status: 'Failed to upload file', errors: uploaded_files.errors.full_messages }, status: 400
        end
    end

    private

    def set_circuit_breaker
        @circuit_breaker ||= CircuitBreaker.new(failure_threshold: 3, recovery_timeout: 30)
    end

    def circuit_breaker
        @circuit_breaker
    end
end
