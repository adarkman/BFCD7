with Ada.Text_IO;

use Ada.Text_IO;

package body LibBFCD.Version is

	procedure Print_Version is
	begin
		Put_Line(Name & " " & Version & " - "& Description);
		Put_Line("Author: " & Author);
		Put_Line(Copyright);
	end Print_Version;

end LibBFCD.Version;

