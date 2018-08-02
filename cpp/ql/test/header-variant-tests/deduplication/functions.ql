import cpp

from Function f, string d, string c
where if f instanceof MemberFunction then (
  d = "MemberFunction" and c = ((MemberFunction)f).getDeclaringType().getName()
) else (
  d = "Function" and c = "<none>"
)
select f, d, count(f.getBlock()), c
