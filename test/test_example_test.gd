# GdUnit generated TestSuite
class_name TestExampleTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://test_example.gd'


func test_full_name() -> void:
	var person = TestExample.new("King", "Arthur")
	assert_str(person.full_name()).is_equal("King Arthur")
	person.free()

