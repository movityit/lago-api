# frozen_string_literal: true

require "rails_helper"

RSpec.describe PaymentProviders::SumupProvider do
  subject(:sumup_provider) { build(:sumup_provider) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:api_key) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to allow_value(nil).for(:success_redirect_url) }
    it { is_expected.to allow_value("https://example.com/success").for(:success_redirect_url) }
    it { is_expected.not_to allow_value("invalid-url").for(:success_redirect_url) }
    it { is_expected.not_to allow_value("a" * 1025).for(:success_redirect_url) }

    it "validates uniqueness of the code" do
      expect(sumup_provider).to validate_uniqueness_of(:code).scoped_to(:organization_id)
    end
  end

  describe "constants" do
    it "defines success redirect URL" do
      expect(described_class::SUCCESS_REDIRECT_URL).to eq("https://sumup.com/")
    end

    it "defines API URL" do
      expect(described_class::API_URL).to eq("https://api.sumup.com/v0.1")
    end

    it "defines processing statuses" do
      expect(described_class::PROCESSING_STATUSES).to eq(%w[PENDING])
    end

    it "defines success statuses" do
      expect(described_class::SUCCESS_STATUSES).to eq(%w[PAID SUCCESSFUL])
    end

    it "defines failed statuses" do
      expect(described_class::FAILED_STATUSES).to eq(%w[FAILED CANCELLED])
    end
  end

  describe "#payment_type" do
    it "returns sumup" do
      expect(sumup_provider.payment_type).to eq("sumup")
    end
  end

  describe "#api_url" do
    it "returns the API URL" do
      expect(sumup_provider.api_url).to eq("https://api.sumup.com/v0.1")
    end
  end

  describe "webhook_secret generation" do
    context "when creating a new provider" do
      it "generates a webhook secret" do
        provider = create(:sumup_provider)
        expect(provider.webhook_secret).to be_present
        expect(provider.webhook_secret.length).to eq(64)
      end

      it "generates different secrets for different providers" do
        provider1 = create(:sumup_provider)
        provider2 = create(:sumup_provider)
        expect(provider1.webhook_secret).not_to eq(provider2.webhook_secret)
      end

      it "does not override existing webhook secret" do
        existing_secret = "existing_secret"
        provider = described_class.new(
          organization: create(:organization),
          name: "Test Provider",
          code: "test_provider",
          api_key: "sup_sk_test_key",
          webhook_secret: existing_secret
        )
        provider.save!
        expect(provider.reload.webhook_secret).to eq(existing_secret)
      end
    end
  end

  describe "SumupPayment" do
    it "defines a data structure for payments" do
      payment = described_class::SumupPayment.new(
        id: "12345",
        status: "PAID",
        metadata: {amount: 1000}
      )

      expect(payment.id).to eq("12345")
      expect(payment.status).to eq("PAID")
      expect(payment.metadata).to eq({amount: 1000})
    end
  end

  describe "secrets accessors" do
    it "provides access to api_key through secrets" do
      provider = create(:sumup_provider, api_key: "sup_sk_test_api_key")
      expect(provider.api_key).to eq("sup_sk_test_api_key")
    end

    it "provides access to webhook_secret through secrets" do
      provider = create(:sumup_provider)
      expect(provider.webhook_secret).to be_present
    end
  end
end
