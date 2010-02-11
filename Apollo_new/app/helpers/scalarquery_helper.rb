module ScalarqueryHelper
  #将字符串数组格式化为字符串
  #array字符串数组:  1,2,3,1,2,12,2
  #total_size整数: 将数组分割成几块，如2,3
  #index整数：格式化其中的第几块
  def Array2String(array, total_size, index)
    blocklen = array.size / total_size
    return array[blocklen*index, blocklen].join(",")
  end
end
