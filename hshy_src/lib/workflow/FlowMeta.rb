$LOAD_PATH.unshift(File.dirname(__FILE__))

require "Flow"
require "EncodeUtil"

class FlowMeta
  class << self
    def LoadAllFlows()
      YtLog.info "loading all workflow..."
      $Workflows.clear
      flows = YtwgWorkflow.find(:all)
      for flow in flows
        #LoadWorkFlow(flow.name, flow.content.sub!('<?xml version="1.0" encoding="gb2312" ?>', ''))
        LoadWorkFlow(flow.name, flow.content, flow.publish_time)
      end
    end
		
    def LoadWorkFlow(name, str, publish_time=Time.new)
      YtLog.info name
      $Workflows[name] = Flow.new(name, str, publish_time)
    end
		
    def Remove(name)
      $Workflows.delete(name)
    end
  end
end