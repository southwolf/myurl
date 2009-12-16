require "Flow"
class FlowProcess 
  attr_accessor :user
  
  def initialize(flow, form, state_name='��ʼ')
    @flow = flow
    @state_name = state_name
    @form = form
    @user = nil
  end
  
  def update_form(value_hash)
    @form.update(value_hash)
  end
  
  #������ʼ�¼�
  def signal_start
    state = @flow.get_state("��ʼ")
    YtLog.info state.enter
    instance_eval(state.enter) if state.enter
  end
  
  #���������¼�
  def signal_enter
    current_state = @flow.get_state(@state_name)
    YtLog.info current_state.enter
    instance_eval(current_state.enter) if current_state.enter
  end
  
  #�����뿪�¼�
  def signal_leave
    current_state = @flow.get_state(@state_name)
    
    newstate = @form._state.split(',')
    for trasit in current_state.trasits
      YtLog.info trasit.condition
      if instance_eval(trasit.condition) || trasit.condition.size ==0
        newstate << trasit.to.name
        
        #ִ���뿪����
        YtLog.info current_state.leave
        instance_eval(current_state.leave) if current_state.leave
      end
    end
    newstate.delete(@state_name)
    newstate.uniq!
    if newstate.size > 0
      @form._state = newstate.join(',')
      @form.save
    end
  end
  
  #�뿪һ��״̬ʱ�������¼�
  def signal
    current_state = @flow.get_state(@state_name)
    for trasit in current_state.trasits
      YtLog.info trasit.condition
      if instance_eval(trasit.condition) || trasit.condition.size ==0
        @state_name = trasit.to.name
        @form._state = @state_name
        
        #ִ���뿪����
        YtLog.info current_state.leave
        instance_eval(current_state.leave)
        
        #ִ��Ŀ��״̬�Ľ��뺯��
        YtLog.info trasit.to.enter
        instance_eval(trasit.to.enter)
        
        @form.save
        break
      end
    end
  end
  
  def method_missing(method_id, *args)
    name = method_id.id2name
    YtLog.info name, "method missing"
    YtLog.info @form[name]
    @form[name]
  end
end