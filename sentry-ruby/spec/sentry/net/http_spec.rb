require "spec_helper"

RSpec.describe Sentry::Net::HTTP do
  context "with tracing enabled" do
    before do
      perform_basic_setup do |config|
        config.traces_sample_rate = 1.0
      end
    end

    it "records the request's transaction" do
      transaction = Sentry.start_transaction
      Sentry.get_current_scope.set_span(transaction)

      response = Net::HTTP.get_response(URI("https://github.com/getsentry/sentry-ruby"))

      expect(response.code).to eq("200")
      expect(transaction.span_recorder.spans.count).to eq(2)

      request_span = transaction.span_recorder.spans.last
      expect(request_span.op).to eq("net.http")
      expect(request_span.start_timestamp).not_to be_nil
      expect(request_span.timestamp).not_to be_nil
      expect(request_span.start_timestamp).not_to eq(request_span.timestamp)
      expect(request_span.description).to eq("GET https://github.com/getsentry/sentry-ruby")
      expect(request_span.data).to eq({ status: 200 })
    end

    it "doesn't mess different requests' data together" do
      transaction = Sentry.start_transaction
      Sentry.get_current_scope.set_span(transaction)

      response = Net::HTTP.get_response(URI("https://github.com/getsentry/sentry-ruby"))
      expect(response.code).to eq("200")

      response = Net::HTTP.get_response(URI("https://github.com/getsentry/sentry-foo"))
      expect(response.code).to eq("404")

      expect(transaction.span_recorder.spans.count).to eq(3)

      request_span = transaction.span_recorder.spans[1]
      expect(request_span.op).to eq("net.http")
      expect(request_span.start_timestamp).not_to be_nil
      expect(request_span.timestamp).not_to be_nil
      expect(request_span.start_timestamp).not_to eq(request_span.timestamp)
      expect(request_span.description).to eq("GET https://github.com/getsentry/sentry-ruby")
      expect(request_span.data).to eq({ status: 200 })

      request_span = transaction.span_recorder.spans[2]
      expect(request_span.op).to eq("net.http")
      expect(request_span.start_timestamp).not_to be_nil
      expect(request_span.timestamp).not_to be_nil
      expect(request_span.start_timestamp).not_to eq(request_span.timestamp)
      expect(request_span.description).to eq("GET https://github.com/getsentry/sentry-foo")
      expect(request_span.data).to eq({ status: 404 })
    end

    context "with unsampled transaction" do
      it "doesn't do anything" do
        transaction = Sentry.start_transaction(sampled: false)
        expect(transaction).not_to receive(:start_child)
        Sentry.get_current_scope.set_span(transaction)

        response = Net::HTTP.get_response(URI("https://github.com/getsentry/sentry-ruby"))

        expect(response.code).to eq("200")
        expect(transaction.span_recorder.spans.count).to eq(1)
      end
    end
  end

  context "without tracing enabled" do
    it "doesn't affect the HTTP lib anything" do
      response = Net::HTTP.get_response(URI("https://www.google.com"))
      expect(response.code).to eq("200")
    end
  end
end