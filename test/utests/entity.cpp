#include <boost/test/unit_test.hpp>

#include "../test_driver.h"

#define TEST_IT(TYPE, BSQ) { std::u8string result; std::u8string expected; tround(createMetaPathName("entity"), TYPE, createBSQONPathName("entity", BSQ), expected, result); checkAndReport(result, expected); }
#define TEST_WITH(TYPE, BSQ, EXPECTED) { std::u8string result; std::u8string orig; tround(createMetaPathName("entity"), TYPE, createBSQONPathName("entity", BSQ), orig, result); checkAndReport(result, EXPECTED); }

BOOST_AUTO_TEST_SUITE(Entity)

std::u8string s_binop1 = u8"Main::BinOp{Main::OpKind#Add, Main::Value{1i}, Main::Value{2i}}";
std::u8string s_binop2 = u8"Main::BinOp{Main::OpKind#Add, Main::BinOp{Main::OpKind#Sub, Main::Value{3i}, Main::Value{2i}}, Main::Value{2i}}";

////
//BaseOps
BOOST_AUTO_TEST_SUITE(BaseOps)
BOOST_AUTO_TEST_CASE(opkind) {
    TEST_IT("Main::OpKind", "entity_opkind.bsqon");
}
BOOST_AUTO_TEST_CASE(value_direct) {
    TEST_IT("Main::Value", "entity_value.bsqon");
}
BOOST_AUTO_TEST_CASE(value_general) {
    TEST_IT("Main::Expression", "entity_value.bsqon");
}
BOOST_AUTO_TEST_SUITE_END() //BaseOps

////
//BinOp
BOOST_AUTO_TEST_SUITE(BinOp)
BOOST_AUTO_TEST_CASE(binop_direct) {
    TEST_WITH("Main::BinOp", "entity_binop.bsqon", s_binop1);
}
BOOST_AUTO_TEST_CASE(binop_general) {
    TEST_WITH("Main::Expression", "entity_binop.bsqon", s_binop1);
}
BOOST_AUTO_TEST_CASE(binop_order) {
    TEST_WITH("Main::Expression", "entity_binop_order.bsqon", s_binop1);
}
BOOST_AUTO_TEST_CASE(binop_one_name) {
    TEST_WITH("Main::Expression", "entity_binop_one_name.bsqon", s_binop1);
}
BOOST_AUTO_TEST_CASE(binop_nested) {
    TEST_WITH("Main::Expression", "entity_binop_nested.bsqon", s_binop2);
}
BOOST_AUTO_TEST_SUITE_END() //BinOp

BOOST_AUTO_TEST_SUITE_END() //Entity
