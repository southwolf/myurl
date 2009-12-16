module YtwgFunctionHelper
  def generate_function_tree
    @roots = YtwgFunction.find(:all, :conditions=>"parent_id is null or parent_id=''")
  end
end
