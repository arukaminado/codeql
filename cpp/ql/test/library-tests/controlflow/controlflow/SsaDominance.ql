/**
 * @name SSA dominance property test
 * @description  SSA dominance property test. SSA definitions *must* dominate all uses
 * @kind test
 */

import cpp
import semmle.code.cpp.controlflow.SSA

/* Count of number of SSA def-use pairs where the defn does not dominate the use.
  Should always be zero *regardless* of the input */

select
count(SsaDefinition d, LocalScopeVariable v, Expr u |
      d.getAUse(v) = u and
      not exists(BasicBlock bd, BasicBlock bu | bd.contains((ControlFlowNode)d) and bu.contains(u) |  
             bbStrictlyDominates(bd, bu)
             or
             exists(int i, int j | bd = bu and bd.getNode(i) = d and bu.getNode(j) = u and i <= j)
          )
)