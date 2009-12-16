$LOAD_PATH.unshift(File.dirname(__FILE__)+"/..")

require "test/unit"
require "State"
require "Trasit"
require "Flow"
require "YtLog"

$Debug_On = true

class TestWorkFlow < Test::Unit::TestCase
	def test_state
		start = State.start
		assert_equal(start.name, "��ʼ")
	end
	
	def test_workflow
		flow = Flow.new("�ɹ����뵥", %!
	<workflow>
    <start right="�ύ�ɹ�����" leave="" x1="20" y1="167" x2="83" y2="220" />
    <state name="������1" right="�豸�鳤����" enter="" leave="" x1="197" y1="175" x2="278" y2="212" />
    <state name="������2" right="�豸�Ƴ�����" enter="" leave="" x1="402" y1="175" x2="486" y2="213" />
    <state name="������3" right="Ժ������" enter="" leave="" x1="654" y1="175" x2="755" y2="216" />
    <end x1="290" y1="316" x2="390" y2="368" enter="" />
    <trasit name="ͬ��" condition="" from="������1" to="����" />
    <trasit name="ͬ��" condition="" from="������2" to="����" />
    <trasit name="ͬ��" condition='pffs3==&quot;1&quot;' from="������3" to="����" />
    <trasit name="�ύ" condition="" from="��ʼ" to="������1" />
    <trasit name="ͬ��(dj&gt;=500)" condition='dj&gt;500 &amp;&amp; pffs1==&quot;1&quot;' from="������1" to="������2" />
    <trasit name="ͬ��(dj&gt;=50000)" condition='dj&gt;=50000 &amp;&amp; pffs2==&quot;1&quot;' from="������2" to="������3" />
    <state name="����" right="�ύ�ɹ�����" enter="" leave="" x1="304" y1="33" x2="390" y2="68" />
    <trasit name="��ͬ��" condition="" from="������1" to="����" />
    <trasit name="��ͬ��" condition="" from="������2" to="����" />
    <trasit name="��ͬ��" condition="" from="������3" to="����" />
    <trasit name="����" condition="" from="����" to="������1" />
</workflow>
		!)
		assert_equal(flow.states[0].name , "��ʼ")
		assert_equal(flow.get_state('������1').name, "������1")
		assert_equal(flow.get_state('��ʼ').trasits.size, 1)
		assert_equal(flow.get_state('������1').trasits.size, 3)
	end
end