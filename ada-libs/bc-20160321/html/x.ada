with Ada.Finalization;
package Containers is
  type Container is abstract tagged private;
private
  type Container is abstract new Ada.Finalization.Controlled with null record;
end Containers;
package Containers.Maps is
  type Map is abstract new Container with private;
  procedure Bind (M : in out Map) is abstract;
private
  type Map is abstract new Container with null record;
end Containers.Maps;
package Containers.Maps.Unbounded is
  type Unbounded_Map is new Map with private;
  procedure Bind (M : in out Unbounded_Map);
private
  type Unbounded_Map is new Map with null record;
  procedure Initialize (M : in out Unbounded_Map);
end Containers.Maps.Unbounded;
package body Containers.Maps.Unbounded is
  procedure Bind (M : in out Unbounded_Map) is
  begin
    null;
  end Bind;
  procedure Initialize (M : in out Unbounded_Map) is
  begin
    null;
  end Initialize;
end Containers.Maps.Unbounded;
generic
  type Map_Base is new Containers.Maps.Map with private;
package Containers.Maps.Synchronized is
  type Synchronized_Map is new Map_Base with private;
  procedure Bind (M : in out Synchronized_Map);
private
  type Synchronized_Map is new Map_Base with null record;
  procedure Initialize (M : in out Synchronized_Map);
end Containers.Maps.Synchronized;
package body Containers.Maps.Synchronized is
  procedure Bind (M : in out Synchronized_Map) is
  begin
    Bind (Map_Base (M));
  end Bind;
  procedure Initialize (M : in out Synchronized_Map) is
  begin
    Initialize (Map_Base (M));
  end Initialize;
end Containers.Maps.Synchronized;
with Containers.Maps.Synchronized;
with Containers.Maps.Unbounded;
package User is
  package Synchronized_Unbounded_Map
  is new Containers.Maps.Synchronized
     (Map_Base => Containers.Maps.Unbounded.Unbounded_Map);
end User;
