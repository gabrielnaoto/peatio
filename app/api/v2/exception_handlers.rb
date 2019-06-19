# encoding: UTF-8
# frozen_string_literal: true

module API::V2
  module ExceptionHandlers
    def self.included(base)
      base.instance_eval do
        rescue_from Grape::Exceptions::ValidationErrors do |e|
          errors_array = e.full_messages.map do |err|
            err.split.last
          end
          Raven.capture_exception(e) if defined?(Raven)
          error!({ errors: errors_array }, 422)
        end

        rescue_from Peatio::Auth::Error do |e|
          report_exception(e)
          Raven.capture_exception(e) if defined?(Raven)
          error!({ errors: ['jwt.decode_and_verify'] }, 401)
        end

        rescue_from ActiveRecord::RecordNotFound do |e|
          Raven.capture_exception(e) if defined?(Raven)
          error!({ errors: ['record.not_found'] }, 404)
        end

        rescue_from :all do |e|
          Raven.capture_exception(e) if defined?(Raven)
          report_exception(e)
          error!({ errors: ['server.internal_error'] }, 500)
        end
      end
    end
  end
end
