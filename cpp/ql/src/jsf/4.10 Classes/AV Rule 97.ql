/**
 * @name No raw arrays in interfaces
 * @description Arrays should not be used in interfaces. Arrays degenerate to pointers when passed as parameters. This array decay problem has long been known to be a source of errors. Consider using std::vector or encapsulating the array in an Array class.
 * @kind problem
 * @problem.severity recommendation
 * @precision high
 * @id cpp/array-in-interface
 * @tags reliability
 *       readability
 *       language-features
 */
import cpp

predicate containsArray(Type t) {
  t instanceof ArrayType
  or containsArray(t.(PointerType).getBaseType())
  or containsArray(t.(SpecifiedType).getBaseType())
  or (containsArray(t.getUnderlyingType()) and not exists(TypedefType allowed | allowed = t |
    allowed.hasGlobalName("jmp_buf") or
    allowed.hasGlobalName("va_list")
  ))
}

predicate functionAPIViolation(MemberFunction f) {
  f.isPublic() and
  containsArray(f.getAParameter().getType())
}

from MemberFunction m
where functionAPIViolation(m)
  and not m.getDeclaringType() instanceof Struct
select m, "Raw arrays should not be used in interfaces. A container class should be used instead."
