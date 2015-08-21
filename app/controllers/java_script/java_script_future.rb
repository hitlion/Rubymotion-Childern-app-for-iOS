module JavaScript
  class FutureProxy
    include JavaScript::BridgeMixin

    javascript_export :b_b_v_j_s_bridged_future

    def initialize( path )
      @path = path
    end

    def name
      @path
    end

    def path
      @path
    end
  end
end

