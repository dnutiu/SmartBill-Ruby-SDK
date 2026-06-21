# frozen_string_literal: true

require "test_helper"

# Version + basic client sanity tests.
module Smartbill
  class TestSdk < Minitest::Test
    include SmartbillTest

    def test_that_it_has_a_version_number
      refute_nil ::Smartbill::Sdk::VERSION
      assert_equal "1.0.0", ::Smartbill::Sdk::VERSION
    end

    def test_client_exposes_all_services
      c = make_client
      assert_kind_of Smartbill::Sdk::Services::InvoicesService, c.invoices
      assert_kind_of Smartbill::Sdk::Services::EstimatesService, c.estimates
      assert_kind_of Smartbill::Sdk::Services::PaymentsService, c.payments
      assert_kind_of Smartbill::Sdk::Services::EmailService, c.email
      assert_kind_of Smartbill::Sdk::Services::ConfigurationService, c.taxes
      assert_kind_of Smartbill::Sdk::Services::StocksService, c.stocks
      assert_same c.taxes, c.series
      c.close
    end

    def test_rate_limiter_blocks_after_max_calls
      limiter = Smartbill::Sdk::Transport::RateLimiter.new(max_calls: 2, window_seconds: 10.0)
      limiter.acquire
      limiter.acquire
      assert_raises(Smartbill::Sdk::RateLimitError) { limiter.acquire }
    end

    def test_enforce_rate_limit_does_not_block_under_limit
      limiter = Smartbill::Sdk::Transport::RateLimiter.new(max_calls: 5, window_seconds: 10.0)
      5.times { limiter.acquire }
      pass
    end
  end
end
