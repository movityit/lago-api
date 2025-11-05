# frozen_string_literal: true

require "rails_helper"

RSpec.describe PaymentProviders::SumupService do
  subject(:sumup_service) { described_class.new(membership.user) }

  let(:membership) { create(:membership) }
  let(:organization) { membership.organization }
  let(:code) { "code_1" }
  let(:name) { "Name 1" }
  let(:api_key) { "sup_sk_test_api_key" }
  let(:success_redirect_url) { Faker::Internet.url }

  describe ".create_or_update" do
    it "creates a sumup provider" do
      expect do
        sumup_service.create_or_update(
          organization:,
          code:,
          name:,
          api_key:,
          success_redirect_url:
        )
      end.to change(PaymentProviders::SumupProvider, :count).by(1)
    end

    context "when code was changed" do
      let(:new_code) { "updated_code_1" }
      let(:sumup_customer) { create(:sumup_customer, payment_provider:, customer:) }
      let(:customer) { create(:customer, organization:) }

      let(:payment_provider) do
        create(
          :sumup_provider,
          organization:,
          code:,
          name:,
          api_key: "sup_sk_old_key"
        )
      end

      before { sumup_customer }

      it "updates payment provider codes of all customers" do
        result = sumup_service.create_or_update(
          id: payment_provider.id,
          organization:,
          code: new_code,
          name:,
          api_key: "sup_sk_new_key"
        )

        expect(result).to be_success
        expect(result.sumup_provider.customers.first.payment_provider_code).to eq(new_code)
      end
    end

    context "when organization already have a sumup provider" do
      let(:sumup_provider) do
        create(:sumup_provider, organization:, api_key: "sup_sk_old_key", code:)
      end

      before { sumup_provider }

      it "updates the existing provider" do
        result = sumup_service.create_or_update(
          organization:,
          code:,
          name:,
          api_key:,
          success_redirect_url:
        )

        expect(result).to be_success

        expect(result.sumup_provider.id).to eq(sumup_provider.id)
        expect(result.sumup_provider.api_key).to eq(api_key)
        expect(result.sumup_provider.code).to eq(code)
        expect(result.sumup_provider.name).to eq(name)
        expect(result.sumup_provider.success_redirect_url).to eq(success_redirect_url)
      end
    end

    context "with validation error" do
      it "returns an error result" do
        result = sumup_service.create_or_update(
          organization:
        )

        expect(result).not_to be_success
        expect(result.error).to be_a(BaseService::ValidationFailure)
        expect(result.error.messages[:api_key]).to eq(["value_is_mandatory"])
      end
    end
  end
end
