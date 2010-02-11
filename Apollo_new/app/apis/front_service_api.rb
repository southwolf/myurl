class ServiceResult < ActionWebService::Struct
  member :errCode, :int
  member :content, :string
end 


class FrontServiceApi < ActionWebService::API::Base  
  api_method :uploadData,
             :expects =>[:string, :string, :string],
             :returns =>[ServiceResult]
  api_method :downloadData,
             :expects =>[:string, :string, :date, :string, :string],
             :returns =>[ServiceResult]
  api_method :downloadAllData,
             :expects =>[:string, :date, :string, :string],
             :returns =>[ServiceResult]
  api_method :downloadDataByTree,
             :expects =>[:string, :string, :date, :string, :string],
             :returns =>[ServiceResult]
  api_method :publishTask,
             :expects =>[:string, :string, :string],
             :returns =>[ServiceResult]
  api_method :downloadTask,
             :expects =>[:string, :string, :string],
             :returns =>[ServiceResult]
  api_method :deleteTask,
             :expects =>[:string, :string, :string],
             :returns =>[ServiceResult]
  api_method :publishDictionary,
             :expects =>[:string, :string, :string],
             :returns =>[ServiceResult]
  api_method :downloadDictionary,
             :expects =>[:string, :string, :string],
             :returns =>[ServiceResult]
  api_method :deleteDictionary,
             :expects =>[:string, :string, :string],
             :returns =>[ServiceResult]
  api_method :publishScriptSuit,
             :expects =>[:string, :string, :string, :string],
             :returns =>[ServiceResult]
  api_method :downloadScriptSuit,
             :expects =>[:string, :string, :string, :string],
             :returns =>[ServiceResult]
  api_method :deleteScriptSuit,
             :expects =>[:string, :string, :string, :string],
             :returns =>[ServiceResult]
end
