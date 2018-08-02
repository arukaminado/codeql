import semmle.code.cpp.Variable
import semmle.code.cpp.Enum
import semmle.code.cpp.exprs.Access

/**
 * A C structure member or C++ non-static member variable.
 */
class Field extends MemberVariable {

  Field() {
    fieldoffsets(this,_,_)
  }

  /**
   * Gets the offset of this field in bytes from the start of its declaring
   * type (on the machine where facts were extracted).
   */
  int getByteOffset() { fieldoffsets(this,result,_) }

  /**
   * Gets the byte offset within `mostDerivedClass` of each occurence of this
   * field within `mostDerivedClass` itself or a base class subobject of
   * `mostDerivedClass`.
   * Note that for fields of virtual base classes, and non-virtual base classes
   * thereof, this predicate assumes that `mostDerivedClass` is the type of the
   * complete most-derived object.
   */
  int getAByteOffsetIn(Class mostDerivedClass) {
    result = mostDerivedClass.getABaseClassByteOffset(getDeclaringType()) +
      getByteOffset()
  }

  /**
   * Holds if the field can be initialized as part of an initializer list. For
   * example, in:
   *
   * struct S {
   *   unsigned int a : 5;
   *   unsigned int : 5;
   *   unsigned int b : 5; 
   * };
   *
   * Fields `a` and `b` are initializable, but the unnamed bitfield is not.
   */
  predicate isInitializable() {
    // All non-bitfield fields are initializable. This predicate is overridden
    // in `BitField` to handle the anonymous bitfield case.
    any()
  }

  /**
   * Gets the zero-based index of the specified field within its enclosing
   * class, counting only fields that can be initialized. This is the order in
   * which the field will be initialized, whether by an initializer list or in a
   * constructor.
   */
  final int getInitializationOrder() {
    exists(Class cls, int memberIndex | 
      this = cls.getCanonicalMember(memberIndex) and
      memberIndex = rank[result + 1](int index |
        cls.getCanonicalMember(index).(Field).isInitializable()
      )
    )
  }
}

/**
 * A C structure member or C++ member variable declared with an explicit size in bits.
 *
 * Syntactically, this looks like `int x : 3` in `struct S { int x : 3; };`.
 */
class BitField extends Field {
  BitField() { bitfield(this,_,_) }

  /**
   * Gets the size of this bitfield in bits (on the machine where facts
   * were extracted).
   */
  int getNumBits() { bitfield(this,result,_) }

  /**
   * Gets the value which appeared after the colon in the bitfield
   * declaration.
   *
   * In most cases, this will give the same value as `getNumBits`. It will
   * only differ when the value after the colon is larger than the size of
   * the variable's type. For example, given `int32_t x : 1234`,
   * `getNumBits` will give 32, whereas `getDeclaredNumBits` will give
   * 1234.
   */
  int getDeclaredNumBits() { bitfield(this,_,result) }

  /**
   * Gets the offset of this bitfield in bits from the byte identified by
   * getByteOffset (on the machine where facts were extracted).
   */
  int getBitOffset() { fieldoffsets(this,_,result) }

  predicate isAnonymous() {
    hasName("(unnamed bitfield)")
  }

  override predicate isInitializable() {
    // Anonymous bitfields are not initializable.
    not isAnonymous()
  }
}
