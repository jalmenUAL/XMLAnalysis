import module namespace sw="Semantic Web" at "SemanticWeb.xq";
import module namespace swrle="Semantic Web Rule Language Engine" at "SWRL.xq";

declare namespace owl="http://www.w3.org/2002/07/owl#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfs="http://www.w3.org/2000/01/rdf-schema#";
declare namespace xsd="http://www.w3.org/2001/XMLSchema#";
declare namespace swrl="http://www.w3.org/2003/11/swrl#";
declare namespace swrlb="http://www.w3.org/2003/11/swrlb#";

let $classes := sw:toClass("#Paper") union sw:toClass("#Researcher")
let $properties := sw:toProperty("#manuscript") union sw:toProperty("#referee")
let $dataproperties := sw:toDataProperty("#studentPaper") union 
sw:toDataProperty("#title") union sw:toDataProperty("#wordCount")
union sw:toDataProperty("#name") union sw:toDataProperty("#isStudent")
let $name := /conference 
 let $ontology1 :=
(for $x in $name/papers/paper return sw:toClassFiller(sw:ID($x/@id),"#Paper") union sw:toDataFiller(sw:ID($x/@id),"studentPaper",$x/@studentPaper,"boolean") union sw:toDataFiller(sw:ID($x/@id),"title",$x/title,"string") union sw:toDataFiller(sw:ID($x/@id),"wordCount",$x/wordCount,"integer")
) 
let $ontology2 :=
(for $y in $name/researchers/researcher return sw:toClassFiller(sw:ID($y/@id),"#Researcher") union sw:toDataFiller(sw:ID($y/@id),"name",$y/name,"string") union sw:toDataFiller(sw:ID($y/@id),"isStudent",$y/@isStudent,"boolean") union sw:toObjectFiller(sw:ID($y/@id),"manuscript",sw:ID($y/@manuscript)) union sw:toObjectFiller(sw:ID($y/@id),"referee",sw:ID($y/@referee)))
return   
let $mapping := $classes union $properties union $dataproperties union $ontology1 union $ontology2
let $variables := swrle:variable("#x") union swrle:variable("#y")
let $classes_rules := sw:toClass("#Student")
let $rule1 := swrle:Imp(
swrle:AtomList(swrle:IndividualPropertyAtom("#referee","#x","#y")),
swrle:AtomList(swrle:IndividualPropertyAtom("#submission","#x","#y")))
let $rule2 := swrle:Imp(
swrle:AtomList(swrle:IndividualPropertyAtom("#manuscript","#x","#y")),
swrle:AtomList(swrle:IndividualPropertyAtom("#author","#y","#x")))
let $rule3 := swrle:Imp(
swrle:AtomList(swrle:DatavaluedPropertyAtomValue("#isStudent","#x","true","http://www.w3.org/2001/XMLSchema#boolean")),
swrle:AtomList(swrle:ClassAtom("#Student","#x")))
let $ruleall := $variables union $classes_rules  union $rule1 union $rule2 union $rule3
return 

let $completion := swrle:swrl(<rdf:RDF> {$mapping} </rdf:RDF>,<rdf:RDF> {$ruleall} </rdf:RDF>) 
return 
let $classes_rules2 := sw:toClass("#PaperLength") union sw:toClass("#NoSelfReview") union
sw:toClass("#NoStudentReviewer") union sw:toClass("#BadPaperCategory")
let $integrity1 :=
swrle:Imp(
swrle:AtomList((swrle:DatavaluedPropertyAtomVars("#wordCount","#x","#y"),swrle:BuiltinAtomArg2("http://www.w3.org/2003/11/swrlb#greaterThanOrEqual","#y","10000","http://www.w3.org/2001/XMLSchema#integer"))),
swrle:AtomList(swrle:ClassAtom("#PaperLength","#x")))
let $integrity2 := 
swrle:Imp(
swrle:AtomList((swrle:IndividualPropertyAtom("#manuscript","#x","#y"),
swrle:IndividualPropertyAtom("#submission","#x","#y"))),
swrle:AtomList(swrle:ClassAtom("#NoSelfReview","#x")))
let $integrity3 := 
swrle:Imp(
swrle:AtomList((swrle:ClassAtom("#Student","#x"),
swrle:IndividualPropertyAtom("#submission","#x","#y"))),
swrle:AtomList(swrle:ClassAtom("#NoStudentReviewer","#x")))
let $integrity4 := swrle:Imp(
swrle:AtomList((swrle:IndividualPropertyAtom("#manuscript","#x","#y"),
swrle:DatavaluedPropertyAtomValue("#isStudent","#x","true","http://www.w3.org/2001/XMLSchema#boolean"),
swrle:DatavaluedPropertyAtomValue("#studentPaper","#y","false","http://www.w3.org/2001/XMLSchema#boolean"))),
swrle:AtomList(swrle:ClassAtom("#BadPaperCategory","#x")))
let $integrity5 := swrle:Imp(
swrle:AtomList((swrle:IndividualPropertyAtom("#author","#x","#y"),
swrle:DatavaluedPropertyAtomValue("#isStudent","#y","true","http://www.w3.org/2001/XMLSchema#boolean"),
swrle:DatavaluedPropertyAtomValue("#studentPaper","#x","false","http://www.w3.org/2001/XMLSchema#boolean"))),
swrle:AtomList(swrle:ClassAtom("#BadPaperCategory","#x")))
let $integrityall := $classes_rules2 union  $integrity1 union $integrity2 union $integrity3 union $integrity4 union $integrity5
return 
swrle:swrl(<rdf:RDF> {$mapping union $completion} </rdf:RDF>,<rdf:RDF> {$integrityall} </rdf:RDF>)
 