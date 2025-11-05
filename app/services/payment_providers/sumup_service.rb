# frozen_string_literal: true

module PaymentProviders
  class SumupService < BaseService
    def create_or_update(**args)
      payment_provider_result = PaymentProviders::FindService.call(
        organization_id: args[:organization].id,
        code: args[:code],
        id: args[:id],
        payment_provider_type: "sumup"
      )

      sumup_provider = if payment_provider_result.success?
        payment_provider_result.payment_provider
      else
        PaymentProviders::SumupProvider.new(
          organization_id: args[:organization].id,
          code: args[:code]
        )
      end

      old_code = sumup_provider.code

      sumup_provider.api_key = args[:api_key] if args.key?(:api_key)
      sumup_provider.success_redirect_url = args[:success_redirect_url] if args.key?(:success_redirect_url)
      sumup_provider.code = args[:code] if args.key?(:code)
      sumup_provider.name = args[:name] if args.key?(:name)
      sumup_provider.save!

      if payment_provider_code_changed?(sumup_provider, old_code, args)
        sumup_provider.customers.update_all(payment_provider_code: args[:code]) # rubocop:disable Rails/SkipsModelValidations
      end

      result.sumup_provider = sumup_provider
      result
    rescue ActiveRecord::RecordInvalid => e
      result.record_validation_failure!(record: e.record)
    end
  end
end
