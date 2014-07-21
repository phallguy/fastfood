module Helpers
  module ServiceHelpers

    def fake_manifest( service )
      buckets  = {}
      manifest = Fastfood::Manifest.new( nil, nil )
      service.stub(:manifest).and_return manifest

      manifest.stub(:find_bucket) do |bucket_name|
        buckets[bucket_name] ||= Fastfood::Manifest::Bucket.new
      end

    end

  end
end