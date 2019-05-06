module namespace sw="Semantic Web";

declare namespace owl="http://www.w3.org/2002/07/owl#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfs="http://www.w3.org/2000/01/rdf-schema#";
declare namespace xsd="http://www.w3.org/2001/XMLSchema#";

(: QUERYING THE ONTOLOGY :)

declare function sw:Classes($item as node()*) as node()* {for $x in $item//owl:Class[@rdf:about] return sw:toClass($x/@rdf:about)};
 
declare function sw:Properties($item as node()*) as node()* {for $x in $item//rdf:Property[@rdf:about] return sw:toProperty($x/@rdf:about)}; 

declare function sw:Individuals($item as node()*) as node()* {for $x in $item//owl:Thing[@rdf:about] return sw:toIndividual($x/@rdf:about)}; 

declare function sw:Unions($item as node()*) as node()* {for $x in $item//owl:Class[owl:unionOf] return sw:toClass($x/@rdf:about)};

declare function sw:Intersections($item as node()*) as node()* {for $x in $item//owl:Class[owl:intersectionOf] return sw:toClass($x/@rdf:about)};

declare function sw:ClassesOfIntersectionsOld($int as node()*) as node()* {
for $x in  $int/owl:intersectionOf/* 
return sw:toComposedClass(concat('#',concat('intersectionOf',string-join($x//@*,' '))),<intersection> $x/* </intersection>)  
};

declare function sw:ClassesOfIntersections($item as node()*) as node()*{
for $x in sw:ClassesOfIntersectionsOld($item) 
order by $x/@rdf:about descending 
return $x
};
 
declare function sw:ClassesOfUnionsOld($int as node()*) as node()* {
for $x in  $int/owl:unionOf/*
return sw:toComposedClass(concat('#',concat('unionOf',string-join($x//@*,' '))),<union> $x/* </union>)
};

declare function sw:ClassesOfUnions($item as node()*) as node()*{
for $x in sw:ClassesOfUnionsOld($item) 
order by $x/@rdf:about descending 
return $x
};

declare function sw:Restrictions($item as node()*) as node()* {for $x in $item//owl:Class[owl:Restriction] return  $x};

(: EQUALITY :)

declare function sw:eq($id1 as xs:string,$id2 as xs:string) as xs:boolean {$id1=$id2 or $id1=concat('#',$id2) or $id2=concat('#',$id1)};

 
(: QUERYING THE TBOX :)

(: EQUIVALENT CLASS :)

declare function sw:equivalentClass($item as node()*,$class as node()) as node()* 
{
(
for $x in $item//owl:Class[owl:equivalentClass/@rdf:resource] 
where sw:eq($x/@rdf:about,$class/@rdf:about) 
return sw:toClass($x/owl:equivalentClass/@rdf:resource)
)
union 
(
for $y in $item//owl:Class[owl:equivalentClass/@rdf:resource] 
where sw:eq($y/owl:equivalentClass/@rdf:resource,$class/@rdf:about) 
return sw:toClass($y/@rdf:about))
union 
(
for $z in $item//owl:Class[owl:equivalentClass/owl:intersectionOf] 
let $u := $z/owl:equivalentClass/owl:intersectionOf
where sw:eq($z/@rdf:about,$class/@rdf:about) 
return $u 
)

union 
(
for $t in $item//owl:Class[owl:equivalentClass/owl:Restriction] 
let $v := $t/owl:equivalentClass/owl:Restriction
where sw:eq($t/@rdf:about,$class/@rdf:about) 
return $v 
)

};

(: SUBCLASS :)

declare function sw:subClassOf($item as node()*,$class as node()) as node()* 
{
(
for $x in $item//owl:Class[rdfs:subClassOf/@rdf:resource] 
where sw:eq($x/@rdf:about,$class/@rdf:about)  
return sw:toClass($x/rdfs:subClassOf/@rdf:resource) 
) 
union 
(
for $x in $item//owl:Class[rdfs:subClassOf/owl:Restriction] 
let $y := $x/rdfs:subClassOf/owl:Restriction
where sw:eq($x/@rdf:about,string($class/@rdf:about)) 
return 
$y
) 
union 
(
for $x in $item//owl:Class[rdfs:subClassOf/owl:intersectionOf] 
let $y := $x/rdfs:subClassOf/owl:intersectionOf
where sw:eq($x/@rdf:about,string($class/@rdf:about))  
return $y 
)
};

(: SUPERCLASS :)
  
declare function sw:superClassOf($item as node()*,$class as node()) as node()*
{
(
for $x in $item//owl:Class[rdfs:subClassOf/@rdf:resource] 
where sw:eq($x/rdfs:subClassOf/@rdf:resource,$class/@rdf:about) 
return sw:toClass($x/@rdf:about))
};

(: EQUIVALENT PROPERTY :)

declare function sw:equivalentProperty($item as node()*,$property as node()) as node()* 
{
(
for $x in $item//rdf:Property[owl:equivalentProperty/@rdf:resource] 
where sw:eq(string($x/@rdf:about),string($property/@rdf:about)) 
return sw:toProperty($x/owl:equivalentProperty/@rdf:resource)  
)
union 
(
for $x in $item//rdf:Property[owl:equivalentProperty/@rdf:resource] 
where sw:eq(string($x/owl:equivalentProperty/@rdf:resource),string($property/@rdf:about)) 
return sw:toProperty($x/@rdf:about)
)
};  

(: SUBPROPERTY :)

declare function sw:subPropertyOf($item as node()*,$property as node()) as node()* 
{
for $x in $item//rdf:Property[rdfs:subPropertyOf/@rdf:resource] 
where sw:eq(string($x/@rdf:about),string($property/@rdf:about)) 
return sw:toProperty($x/rdfs:subPropertyOf/@rdf:resource)  
};


(: SUPERPROPERTY:)
 
declare function sw:superPropertyOf($item as node()*,$property as node()) as node()*
{
for $x in $item//rdf:Property[rdfs:subPropertyOf/@rdf:resource] 
where sw:eq(string($x/rdfs:subPropertyOf/@rdf:resource),string($property/@rdf:about)) 
return sw:toProperty($x/@rdf:about)
};

(: INVERSE OF :)

declare function sw:inverseOf($item as node()*, $property as node()) as node()*
{
(
for $x in $item//rdf:Property[owl:inverseOf] 
where sw:eq(string($x/@rdf:about),string($property/@rdf:about)) 
return sw:toProperty($x/owl:inverseOf/@rdf:resource) 
) 
union 
(for $x in $item//rdf:Property[owl:inverseOf] 
where sw:eq(string($x/owl:inverseOf/@rdf:resource),string($property/@rdf:about)) 
return sw:toProperty($x/@rdf:about)
)
};

(: TRANSITIVE :) 

declare function sw:TransitiveProperty($item as node()*) as node()*{
for $x in $item//owl:TransitiveProperty 
return sw:toProperty($x/@rdf:about)  
};

(: SYMMETRIC :)

declare function sw:SymmetricProperty($item as node()*) as node()*{
for $x in $item//owl:SymmetricProperty 
return sw:toProperty($x/@rdf:about) 
};

(: DOMAIN :)
 
declare function sw:domain($item as node()*,$property as node()) as node()*
{
for $x in $item//rdf:Property where sw:eq($property/@rdf:about,$x/@rdf:about) return 
sw:toClass($x/rdfs:domain/@rdf:resource)  
};

(: RANGE :)

declare function sw:range($item as node()*,$property as node()) as node()*
{
for $x in $item//rdf:Property where sw:eq($property/@rdf:about,$x/@rdf:about) return
sw:toClass($x/rdfs:range/@rdf:resource)   
};

(: TYPE AND ROLE :)

declare function sw:type($item as node()*,$individual as xs:string) as node()*
{
for $x in sw:abox($item) 
where sw:property($x)="rdf:type" and sw:eq(sw:subject($x),$individual) return sw:toClass(sw:object($x))
};

declare function sw:oftype($item as node()*,$class as xs:string) as node()*
{
for $x in sw:abox($item) 
where sw:property($x)="rdf:type" and sw:eq(sw:object($x),$class) return sw:toIndividual(sw:subject($x))
};

declare function sw:role($item as node()*,$individual1 as xs:string, $individual2 as xs:string) as node()*
{
for $x in sw:abox($item) 
where sw:eq(sw:subject($x),$individual1) and sw:eq(sw:object($x),$individual2)  return sw:toProperty(sw:property($x))
};

declare function sw:ofrole($item as node()*,$property as xs:string) as node()*
{
for $x in sw:abox($item) 
where sw:eq(sw:property($x),$property) return $x
};



 
(: REPRESENTATION :)


declare function sw:toClass($x as xs:string) as node()*
{
<owl:Class   rdf:about="{$x}" /> 
};


declare function sw:toComposedClass($x as xs:string, $y as node()*) as node()*
{
<owl:Class xmlns:owl="http://www.w3.org/2002/07/owl#"  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" rdf:about="{$x}"> { for $z in $y return  $z } </owl:Class> 
};

declare function sw:toProperty($x as xs:string) as node()*
{
<rdf:Property   rdf:about="{$x}" />
};

declare function sw:toDataProperty($x as xs:string) as node()*
{
<owl:DatatypeProperty   rdf:about="{$x}" />
};

declare function sw:toIndividual($x as xs:string) as node()*
{
<owl:Thing   rdf:about="{$x}" /> 
};

declare function sw:toClassFiller($x as xs:string, $type as xs:string) as node()*
{
<owl:Thing   rdf:about="{$x}"> <rdf:type rdf:resource="{$type}"/> </owl:Thing> 
};

declare function sw:toObjectFiller($x as xs:string,$p as xs:string,$y as xs:string) as node()*
{
<owl:Thing   rdf:about="{$x}" >
{ 
element {$p} {attribute {QName("http://www.w3.org/1999/02/22-rdf-syntax-ns#",'rdf:resource')} {$y}}  
}
</owl:Thing> 
};

declare function sw:toDataFiller($x as xs:string,$p as xs:string,$y as xs:string,$type as xs:string) as node()*
{
<owl:Thing    rdf:about="{$x}" >
{ 
element {$p} {attribute {QName("http://www.w3.org/1999/02/22-rdf-syntax-ns#",'rdf:datatype')} {concat("http://www.w3.org/2001/XMLSchema#",$type)}, $y}  
}
</owl:Thing> 
};

(: QUERYING THE ABOX :)

declare function sw:abox($x as node()*) as node()*
{
$x//owl:Thing[@rdf:about]
 };

declare function sw:subject($x as node()) as xs:string
{
string($x/@rdf:about)
};

declare function sw:property($x as node()) as xs:string
{
string(node-name($x/*))
};

declare function sw:object($x as node()) as xs:string
{
string($x/*/@rdf:resource)
};



declare function sw:About($x as node()) as xs:string
{
string($x/@rdf:about)
};

declare function sw:Resource($x as node()) as xs:string
{
string($x/*/@rdf:resource)
};

declare function sw:ID($x as xs:string){
concat('#',$x)
};
