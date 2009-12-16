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
		assert_equal(start.name, "开始")
	end
	
	def test_workflow
		flow = Flow.new("采购申请单", %!
	<workflow>
    <start right="提交采购申请" leave="" x1="20" y1="167" x2="83" y2="220" />
    <state name="待审批1" right="设备组长审批" enter="" leave="" x1="197" y1="175" x2="278" y2="212" />
    <state name="待审批2" right="设备科长审批" enter="" leave="" x1="402" y1="175" x2="486" y2="213" />
    <state name="待审批3" right="院长审批" enter="" leave="" x1="654" y1="175" x2="755" y2="216" />
    <end x1="290" y1="316" x2="390" y2="368" enter="" />
    <trasit name="同意" condition="" from="待审批1" to="结束" />
    <trasit name="同意" condition="" from="待审批2" to="结束" />
    <trasit name="同意" condition='pffs3==&quot;1&quot;' from="待审批3" to="结束" />
    <trasit name="提交" condition="" from="开始" to="待审批1" />
    <trasit name="同意(dj&gt;=500)" condition='dj&gt;500 &amp;&amp; pffs1==&quot;1&quot;' from="待审批1" to="待审批2" />
    <trasit name="同意(dj&gt;=50000)" condition='dj&gt;=50000 &amp;&amp; pffs2==&quot;1&quot;' from="待审批2" to="待审批3" />
    <state name="撤销" right="提交采购申请" enter="" leave="" x1="304" y1="33" x2="390" y2="68" />
    <trasit name="不同意" condition="" from="待审批1" to="撤销" />
    <trasit name="不同意" condition="" from="待审批2" to="撤销" />
    <trasit name="不同意" condition="" from="待审批3" to="撤销" />
    <trasit name="重做" condition="" from="撤销" to="待审批1" />
</workflow>
		!)
		assert_equal(flow.states[0].name , "开始")
		assert_equal(flow.get_state('待审批1').name, "待审批1")
		assert_equal(flow.get_state('开始').trasits.size, 1)
		assert_equal(flow.get_state('待审批1').trasits.size, 3)
	end
end