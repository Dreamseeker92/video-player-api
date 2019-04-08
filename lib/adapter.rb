require 'linguistics'

module ApiVideos
  class Adapter
    def table_name
      Linguistics.use :en
      self.class.name.en.plural
    end

    def create; raise NotImplementedError; end

    def find_by_id; raise NotImplementedError; end
  end
end
