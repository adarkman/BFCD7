
package body LibBFCD.Vocabulary is

	function Create (Name : in Wide_String) return Vocabulary_Ptr is
		voc : Vocabulary_Ptr := new Vocabulary;
	begin
		voc.Name := new Wide_String'(Name);
		return voc;
	end Create;

end LibBFCD.Vocabulary;

