module namespace swrle="Semantic Web Rule Language Engine";

declare namespace owl="http://www.w3.org/2002/07/owl#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfs="http://www.w3.org/2000/01/rdf-schema#";
declare namespace xsd="http://www.w3.org/2001/XMLSchema#";
declare namespace swrl="http://www.w3.org/2003/11/swrl#";

declare function swrle:variable($x as xs:string)
{
<swrl:Variable rdf:about="{$x}"/>

};

(: BUILTIN :)

declare function swrle:equal($x as node() ,$y as node()) as  xs:boolean{
($x = $y)
};

declare function swrle:notEqual($x as node() ,$y as node()) as  xs:boolean{
not ($x = $y)
};

declare function swrle:lessThan($x as xs:float,$y as xs:float) as xs:boolean{
$x - $y < 0
};

declare function swrle:greaterThanOrEqual($x as xs:float,$y as xs:float) as xs:boolean{
$x - $y >= 0 
};

(: SWRL REPRESENTATION :)

declare function swrle:AtomListAux($Node){
if (count($Node)=1) then  
                <rdf:rest rdf:resource="http://www.w3.org/1999/02/22-rdf-syntax-ns#nil"/>
                union
                <rdf:first>
                    {$Node}
                </rdf:first>
            
else  					<rdf:first>
                    {$Node[1]}
                </rdf:first> 
                union
                <rdf:rest> {swrle:AtomList(remove($Node,1))}
								</rdf:rest>
};

declare function swrle:AtomList($Node){
<swrl:AtomList>
{swrle:AtomListAux($Node)}
</swrl:AtomList>
};

declare function swrle:Imp($Antecedent,$Consequent){
<swrl:Imp>
        <swrl:body>
             {$Antecedent}
        </swrl:body>
        <swrl:head>
             {$Consequent}
        </swrl:head>
</swrl:Imp>

};

declare function swrle:IndividualPropertyAtom($Property,$Var1,$Var2){
											<swrl:IndividualPropertyAtom>
                        <swrl:propertyPredicate rdf:resource="{$Property}"/>
                        <swrl:argument1 rdf:resource="{$Var1}"/>
                        <swrl:argument2 rdf:resource="{$Var2}"/>
                    </swrl:IndividualPropertyAtom>
};

declare function swrle:BuiltinAtomArg2($Builtin,$Arg1,$Arg2,$Datatype)
{
<swrl:BuiltinAtom>
                                <swrl:builtin rdf:resource="{$Builtin}"/>
                                <swrl:arguments>
                                    <rdf:Description>
                                        <rdf:type rdf:resource="http://www.w3.org/1999/02/22-rdf-syntax-ns#List"/>
                                        <rdf:first rdf:resource="{$Arg1}"/>
                                        <rdf:rest>
                                            <rdf:Description>
                                                <rdf:type rdf:resource="http://www.w3.org/1999/02/22-rdf-syntax-ns#List"/>
                                                <rdf:first rdf:datatype="{$Datatype}">{$Arg2}</rdf:first>
                                                <rdf:rest rdf:resource="http://www.w3.org/1999/02/22-rdf-syntax-ns#nil"/>
                                            </rdf:Description>
                                        </rdf:rest>
                                    </rdf:Description>
                                </swrl:arguments>
                            </swrl:BuiltinAtom>
};

declare function swrle:BuiltinAtomArg1($Builtin,$Arg1,$Datatype,$Arg2)
{
<swrl:BuiltinAtom>
                        <swrl:builtin rdf:resource="{$Builtin}"/>
                        <swrl:arguments>
                            <rdf:Description>
                                <rdf:type rdf:resource="http://www.w3.org/1999/02/22-rdf-syntax-ns#List"/>
                                <rdf:first rdf:datatype="{$Datatype}">{$Arg1}</rdf:first>
                                <rdf:rest rdf:parseType="Collection">
                                    <rdf:Description rdf:about="{$Arg2}"/>
                                </rdf:rest>
                            </rdf:Description>
                        </swrl:arguments>
                    </swrl:BuiltinAtom>
};

declare function swrle:DatavaluedPropertyAtomVars($Property,$Arg1,$Arg2){
<swrl:DatavaluedPropertyAtom>
                        <swrl:propertyPredicate rdf:resource="{$Property}"/>
                        <swrl:argument1 rdf:resource="{$Arg1}"/>
                        <swrl:argument2 rdf:resource="{$Arg2}"/>
                    </swrl:DatavaluedPropertyAtom>
};

declare function swrle:DatavaluedPropertyAtomValue($Property,$Arg1,$Arg2,$Datatype){
<swrl:DatavaluedPropertyAtom>
                                        <swrl:argument2 rdf:datatype="{$Datatype}">{$Arg2}</swrl:argument2>
                                        <swrl:propertyPredicate rdf:resource="{$Property}"/>
                                        <swrl:argument1 rdf:resource="{$Arg1}"/>
                                    </swrl:DatavaluedPropertyAtom>
};
declare function swrle:ClassAtom($Class,$Arg){
<swrl:ClassAtom>
                        <swrl:classPredicate rdf:resource="{$Class}"/>
                        <swrl:argument1 rdf:resource="{$Arg}"/>
                    </swrl:ClassAtom>
};

declare function swrle:SameIndividualAtom($Arg1,$Arg2){
<swrl:SameIndividualAtom>
                                <swrl:argument1 rdf:resource="{$Arg1}"/>
                                <swrl:argument2 rdf:resource="{$Arg2}"/>
                            </swrl:SameIndividualAtom>
};

declare function swrle:DifferentIndividualsAtom($Arg1,$Arg2){
<swrl:DifferentIndividualsAtom>
                                <swrl:argument1 rdf:resource="{$Arg1}"/>
                                <swrl:argument2 rdf:resource="{$Arg2}"/>
                            </swrl:DifferentIndividualsAtom>
};



 
(: AUXILIARY :)

declare function swrle:substring-after-namespace($string as xs:string ,$char as xs:string) as xs:string
{
 
if  (substring-after($string,$char)="") then $string else substring-after($string,$char)
 
};


declare function swrle:range-property($prop as node()) as xs:string{
if ($prop/@rdf:resource) then $prop/@rdf:resource  
else $prop/text() 
};

declare function swrle:domain-property($prop as node()) as xs:string{
$prop/../@rdf:about
};

declare function swrle:ClassesThing($doc as node()*) as node()*
{
$doc//owl:Thing[rdf:type]
};

declare function swrle:PropertiesThing($doc as node()*) as node()*
{
$doc//owl:Thing[not (rdf:type)]
union
(
for $different in $doc//rdf:Description/owl:distinctMembers  
let $elem1 := ($different/rdf:Description)[1]
let $elem2 := ($different/rdf:Description)[2]
return
<owl:Thing xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:owl="http://www.w3.org/2002/07/owl#" rdf:about="{$elem1/@rdf:about}"> 
<owl:differentFrom rdf:resource="{$elem2/@rdf:about}"/>
</owl:Thing>
union
<owl:Thing xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:owl="http://www.w3.org/2002/07/owl#" rdf:about="{$elem2/@rdf:about}"> 
<owl:differentFrom rdf:resource="{$elem1/@rdf:about}"/>
</owl:Thing>
)

};

declare function swrle:Classes($doc as node()*) as node()*
{
(
for $elements in $doc//owl:Thing  
return
for $type in 
$elements/rdf:type
return
<owl:Thing xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:owl="http://www.w3.org/2002/07/owl#" rdf:about="{$elements/@rdf:about}">
{$type}
</owl:Thing>
)
union
(
for $elements in $doc//*[rdf:type/@rdf:resource="http://www.w3.org/2002/07/owl#Thing"]  
return <owl:Thing xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:owl="http://www.w3.org/2002/07/owl#" rdf:about="{$elements/@rdf:about}"> 
<rdf:type rdf:resource="{concat("#",node-name($elements))}"/>
</owl:Thing>
)
 
};




declare function swrle:Properties($doc as node()*) as node()*
{
(
for $elements in ($doc//owl:Thing)  
for $items in $elements/* where not(string(node-name($items))="rdf:type") return
<owl:Thing xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:owl="http://www.w3.org/2002/07/owl#" rdf:about="{$elements/@rdf:about}"> 
{$items}
</owl:Thing>
)
union
(
for $elements in $doc//*[rdf:type/@rdf:resource="http://www.w3.org/2002/07/owl#Thing"]  
for $items in $elements/* where not(string(node-name($items))="rdf:type") return
<owl:Thing xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:owl="http://www.w3.org/2002/07/owl#" rdf:about="{$elements/@rdf:about}"> 
{$items}
</owl:Thing> 
)
union
(
for $different in $doc//rdf:Description/owl:distinctMembers  
let $elem1 := ($different/rdf:Description)[1]
let $elem2 := ($different/rdf:Description)[2]
return
<owl:Thing xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:owl="http://www.w3.org/2002/07/owl#" rdf:about="{$elem1/@rdf:about}"> 
<owl:differentFrom rdf:resource="{$elem2/@rdf:about}"/>
</owl:Thing>
union
<owl:Thing xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:owl="http://www.w3.org/2002/07/owl#" rdf:about="{$elem2/@rdf:about}"> 
<owl:differentFrom rdf:resource="{$elem1/@rdf:about}"/>
</owl:Thing>
)
};


(: SWRL ENGINE :)
 
declare function swrle:evaluate-head($Head as node()*,$Binding as node()*) as node()*
{

if ($Head/rdf:rest/@rdf:resource="http://www.w3.org/1999/02/22-rdf-syntax-ns#nil") then
swrle:compute-head($Head/rdf:first,$Binding)
else (swrle:compute-head($Head/rdf:first,$Binding) union swrle:evaluate-head($Head/rdf:rest/swrl:AtomList,$Binding))

};

declare function swrle:compute-head($Head as node()*,$Binding as node()*) as node()*
{
if ($Head/swrl:ClassAtom) then 
<owl:Thing xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:owl="http://www.w3.org/2002/07/owl#" 
rdf:about="{swrle:asignment($Binding,$Head/swrl:ClassAtom/swrl:argument1/@rdf:resource)}"> 
<rdf:type rdf:resource="{$Head/swrl:ClassAtom/swrl:classPredicate/@rdf:resource}"/>
</owl:Thing> 
else if ($Head/swrl:IndividualPropertyAtom[swrl:argument2/@rdf:resource]) then (:CHANGE:)

<owl:Thing xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:owl="http://www.w3.org/2002/07/owl#" 
rdf:about="{swrle:asignment($Binding,$Head/swrl:IndividualPropertyAtom/swrl:argument1/@rdf:resource)}"> 
{
element {substring($Head/swrl:IndividualPropertyAtom/swrl:propertyPredicate/@rdf:resource,2,1000)} {attribute {QName("http://www.w3.org/1999/02/22-rdf-syntax-ns#",'rdf:resource')} 
{swrle:asignment($Binding,$Head/swrl:IndividualPropertyAtom/swrl:argument2/@rdf:resource)}} 
}
</owl:Thing>
else if ($Head/swrl:IndividualPropertyAtom[swrl:argument2/@rdf:datatype]) then (:CHANGE:)

<owl:Thing xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:owl="http://www.w3.org/2002/07/owl#" 
rdf:about="{swrle:asignment($Binding,$Head/swrl:IndividualPropertyAtom/swrl:argument1/@rdf:resource)}"> 
{
element {substring($Head/swrl:IndividualPropertyAtom/swrl:propertyPredicate/@rdf:resource,2,1000)} {attribute {QName("http://www.w3.org/1999/02/22-rdf-syntax-ns#",'rdf:resource')} 
{swrle:asignment($Binding,$Head/swrl:IndividualPropertyAtom/swrl:argument2/text())}} 
}
</owl:Thing>
else
if ($Head/swrl:DatavaluedPropertyAtom[swrl:argument2/@rdf:resource]) then (: CHANGE :)
<owl:Thing xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:owl="http://www.w3.org/2002/07/owl#" 
rdf:about="{swrle:asignment($Binding,$Head/swrl:DatavaluedPropertyAtom/swrl:argument1/@rdf:resource)}"> 
{
element {substring($Head/swrl:DatavaluedPropertyAtom/swrl:propertyPredicate/@rdf:resource,2,1000)}
 { swrle:asignment($Binding,$Head/swrl:DatavaluedPropertyAtom/swrl:argument2/@rdf:resource)}} 

</owl:Thing>
else 
if ($Head/swrl:DatavaluedPropertyAtom[swrl:argument2/@rdf:datatype]) then (: CHANGE :)
<owl:Thing xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:owl="http://www.w3.org/2002/07/owl#" 
rdf:about="{swrle:asignment($Binding,$Head/swrl:DatavaluedPropertyAtom/swrl:argument1/@rdf:resource)}"> 
{
element {substring($Head/swrl:DatavaluedPropertyAtom/swrl:propertyPredicate/@rdf:resource,2,1000)}
 { swrle:asignment($Binding,$Head/swrl:DatavaluedPropertyAtom/swrl:argument2/text())}} 

</owl:Thing>

else if ($Head/swrl:SameIndividualAtom) then
<owl:Thing xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:owl="http://www.w3.org/2002/07/owl#" 
rdf:about="{swrle:asignment($Binding,$Head/swrl:SameIndividualAtom/swrl:argument1/@rdf:resource)}"> 
<owl:sameAs rdf:resource="{swrle:asignment($Binding,$Head/swrl:SameIndividualAtom/swrl:argument2/@rdf:resource)}" />
</owl:Thing>
else
if ($Head/swrl:DifferentIndividualsAtom) then
<rdf:Description xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:owl="http://www.w3.org/2002/07/owl#">
        <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#AllDifferent"/>
        <owl:distinctMembers rdf:parseType="Collection">
            <rdf:Description rdf:about="{swrle:asignment($Binding,$Head/swrl:DifferentIndividualsAtom/swrl:argument1/@rdf:resource)}"/>
            <rdf:Description rdf:about="{swrle:asignment($Binding,$Head/swrl:DifferentIndividualsAtom/swrl:argument2/@rdf:resource)}"/>
        </owl:distinctMembers>
    </rdf:Description>
else ()
};


declare function swrle:asignment($Binding as node()*, $var as xs:string) as node()*
{
($Binding//var[swrle:substring-after-namespace(@rdf:about,'#')=swrle:substring-after-namespace($var,'#')]) 
};


declare function swrle:asignment-builtin($Binding as node()*, $object as node()) as node()*
{

if ($object/@rdf:resource) then
$Binding//var[swrle:substring-after-namespace(@rdf:about,'#')=swrle:substring-after-namespace($object/@rdf:resource,'#')]/text()
else if ($object/@rdf:about) then
$Binding//var[swrle:substring-after-namespace(@rdf:about,'#')=swrle:substring-after-namespace($object/@rdf:about,'#')]/text()
else $object/text()
};




declare function swrle:builtin($doc as node()*,$pos as xs:integer,$Atom as node()*,$Binding as node()*)
{
let $args := (
if ($Atom/swrl:arguments/@rdf:parseType="Collection") then
(let $args := $Atom/swrl:arguments/rdf:Description/@rdf:about
return
(let $arg1 := $args[1] return $arg1,
let $arg2 := $args[2] return $arg2)
)
else
if ($Atom/swrl:arguments/rdf:Description/rdf:rest/rdf:Description/@rdf:about)
then 
(let $arg1:=$Atom/swrl:arguments/rdf:Description/rdf:first return $arg1,
let $arg2:=$Atom/swrl:arguments/rdf:Description/rdf:rest/rdf:Description
return $arg2)
else
(let $arg1:= $Atom/swrl:arguments/rdf:Description/rdf:first return $arg1,
let $arg2:= $Atom/swrl:arguments/rdf:Description/rdf:rest/rdf:Description/rdf:first
return $arg2)
)
return
if ($Atom/swrl:builtin/@rdf:resource="http://www.w3.org/2003/11/swrlb#greaterThanOrEqual")
then
if (swrle:greaterThanOrEqual(swrle:asignment-builtin($Binding,$args[1]),swrle:asignment-builtin($Binding,$args[2]))) then $Binding else <binding result="fail"/>  
else 
if ($Atom/swrl:builtin/@rdf:resource="http://www.w3.org/2003/11/swrlb#lessThan")
then
if (swrle:lessThan(swrle:asignment-builtin($Binding,$args[1]),swrle:asignment-builtin($Binding,$args[2]))) then $Binding else <binding result="fail"/>
else
if ($Atom/swrl:builtin/@rdf:resource="http://www.w3.org/2003/11/swrlb#notEqual")
then 
if (swrle:notEqual(swrle:asignment-builtin($Binding,$args[1]),swrle:asignment-builtin($Binding,$args[2]))) then $Binding 
else <binding result="fail"/> else
if ($Atom/swrl:builtin/@rdf:resource="http://www.w3.org/2003/11/swrlb#equal")
then 
if (swrle:equal(swrle:asignment-builtin($Binding,$args[1]),swrle:asignment-builtin($Binding,$args[2]))) then $Binding else <binding result="fail"/>
else <binding result="fail"/>

};

declare function swrle:propertyPredicate($doc as node()*,$pos as xs:integer,$Atom as node()*,$Binding as node()*){
if ($Atom/swrl:argument2/@rdf:resource) then swrle:propertyPredicate1($doc,$pos,$Atom,$Binding)
else swrle:propertyPredicate2($doc,$pos,$Atom,$Binding)
};

declare function swrle:propertyPredicate1($doc as node()*,$pos as xs:integer,$Atom as node()*,$Binding as node()*){
let $prop := $doc[$pos]/*
return
if (empty(swrle:asignment($Binding,$Atom/swrl:argument1/@rdf:resource)) and empty(swrle:asignment($Binding,$Atom/swrl:argument2/@rdf:resource))) 
then 
(<binding case="1" > {$Atom/swrl:propertyPredicate/@rdf:resource} 
<var xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
rdf:about="{string($Atom/swrl:argument2/@rdf:resource)}">  
{string(swrle:range-property($prop))} 
</var>
<var xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
rdf:about="{string($Atom/swrl:argument1/@rdf:resource)}">
{string($doc[$pos]/@rdf:about)} 
</var>
</binding>) union $Binding
else 
if (empty(swrle:asignment($Binding,$Atom/swrl:argument1/@rdf:resource)))
then 
if (swrle:asignment($Binding,$Atom/swrl:argument2/@rdf:resource)=string(swrle:range-property($prop)))
then 
(<binding case="2" > {$Atom/swrl:propertyPredicate/@rdf:resource} 
<var xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
rdf:about="{string($Atom/swrl:argument1/@rdf:resource)}">  
{string(swrle:domain-property($prop))} </var>
</binding>) union $Binding
else 
<binding result="fail"/>
else 
if (empty(swrle:asignment($Binding,$Atom/swrl:argument2/@rdf:resource)))
then 
if (swrle:asignment($Binding,$Atom/swrl:argument1/@rdf:resource)=string(swrle:domain-property($prop)))
then 
(<binding case="3" > {$Atom/swrl:propertyPredicate/@rdf:resource} 
<var xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
rdf:about="{string($Atom/swrl:argument2/@rdf:resource)}">  
{string(swrle:range-property($prop))} </var>
</binding>) union $Binding
else 
<binding result="fail"/>
else 
if (swrle:asignment($Binding,$Atom/swrl:argument2/@rdf:resource)=string(swrle:range-property($prop)) and 
swrle:asignment($Binding,$Atom/swrl:argument1/@rdf:resource)=string(swrle:domain-property($prop))) then $Binding
else <binding result="fail"/>

};

declare function swrle:propertyPredicate2($doc as node()*,$pos as xs:integer,$Atom as node()*,$Binding as node()*){
let $prop := $doc[$pos]/*
return
if (empty(swrle:asignment($Binding,$Atom/swrl:argument1/@rdf:resource)))
then 
     if ($Atom/swrl:argument2/text()=swrle:range-property($prop))
     then 
     (<binding case="1" > {$Atom/swrl:propertyPredicate/@rdf:resource} 
      <var xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
     rdf:about="{string($Atom/swrl:argument1/@rdf:resource)}">  
     {string(swrle:domain-property($prop))} </var>
     </binding>) union $Binding
     else 
     <binding result="fail"/>
else 
     if (swrle:asignment($Binding,$Atom/swrl:argument1/@rdf:resource)=string(swrle:domain-property($prop))
	and $Atom/swrl:argument2/text()=swrle:range-property($prop))
     then 
     $Binding
     else 
     <binding result="fail"/>

};


declare function swrle:classPredicate($doc as node()*,$pos as xs:integer,$Atom as node()*,$Binding as node()*)
{
let $prop := $doc[$pos]
return
 
   if (empty(swrle:asignment($Binding,$Atom/swrl:argument1/@rdf:resource))) 
   then
   ((<binding case="4" > {$Atom/swrl:classPredicate/@rdf:resource} 
   <var xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
   rdf:about="{string($Atom/swrl:argument1/@rdf:resource)}">  
   {string($prop/@rdf:about)} </var>
   </binding>) union $Binding)
   else 
   if (swrle:asignment($Binding,$Atom/swrl:argument1/@rdf:resource)=$prop/@rdf:about)
     then $Binding
     else <binding result="fail"/> 
  
};


declare function swrle:SameIndividualAtom($doc as node()*,$pos as xs:integer,$Atom as node()*,$Binding as node()*)
{
let $prop := $doc[$pos]/*
return
if (empty(swrle:asignment($Binding,$Atom/swrl:argument1/@rdf:resource)) and empty(swrle:asignment($Binding,$Atom/swrl:argument2/@rdf:resource))) 
then 
(<binding case="1" >   
<var xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
rdf:about="{string($Atom/swrl:argument2/@rdf:resource)}">  
{string(swrle:range-property($prop))} 
</var>
<var xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
rdf:about="{string($Atom/swrl:argument1/@rdf:resource)}">
{string($doc[$pos]/@rdf:about)} 
</var>
</binding>) union $Binding
else 
if (empty(swrle:asignment($Binding,$Atom/swrl:argument1/@rdf:resource)))
then 
if (swrle:asignment($Binding,$Atom/swrl:argument2/@rdf:resource)=string(swrle:range-property($prop)))
then 
(<binding case="2" >   
<var xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
rdf:about="{string($Atom/swrl:argument1/@rdf:resource)}">  
{string(swrle:domain-property($prop))} </var>
</binding>) union $Binding
else 
<binding result="fail"/>
else 
if (empty(swrle:asignment($Binding,$Atom/swrl:argument2/@rdf:resource)))
then 
if (swrle:asignment($Binding,$Atom/swrl:argument1/@rdf:resource)=string(swrle:domain-property($prop)))
then 
(<binding case="3" >  
<var xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
rdf:about="{string($Atom/swrl:argument2/@rdf:resource)}">  
{string(swrle:range-property($prop))} </var>
</binding>) union $Binding
else 
<binding result="fail"/>
else 
if (swrle:asignment($Binding,$Atom/swrl:argument2/@rdf:resource)=string(swrle:range-property($prop)) and swrle:asignment($Binding,$Atom/swrl:argument1/@rdf:resource)=string(swrle:domain-property($prop))) then $Binding
else <binding result="fail"/>
};

declare function swrle:DifferentIndividualsAtom($doc as node()*,$pos as xs:integer,$Atom as node()*,$Binding as node()*)
{
let $prop := $doc[$pos]/*
return
if (empty(swrle:asignment($Binding,$Atom/swrl:argument1/@rdf:resource)) and empty(swrle:asignment($Binding,$Atom/swrl:argument2/@rdf:resource))) 
then 
(<binding case="1" >   
<var xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
rdf:about="{string($Atom/swrl:argument2/@rdf:resource)}">  
{string(swrle:range-property($prop))} 
</var>
<var xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
rdf:about="{string($Atom/swrl:argument1/@rdf:resource)}">
{string($doc[$pos]/@rdf:about)} 
</var>
</binding>) union $Binding
else 
if (empty(swrle:asignment($Binding,$Atom/swrl:argument1/@rdf:resource)))
then 
if (swrle:asignment($Binding,$Atom/swrl:argument2/@rdf:resource)=string(swrle:range-property($prop)))
then 
(<binding case="2" >   
<var xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
rdf:about="{string($Atom/swrl:argument1/@rdf:resource)}">  
{string(swrle:domain-property($prop))} </var>
</binding>) union $Binding
else 
<binding result="fail"/>
else 
if (empty(swrle:asignment($Binding,$Atom/swrl:argument2/@rdf:resource)))
then 
if (swrle:asignment($Binding,$Atom/swrl:argument1/@rdf:resource)=string(swrle:domain-property($prop)))
then 
(<binding case="3" >  
<var xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
rdf:about="{string($Atom/swrl:argument2/@rdf:resource)}">  
{string(swrle:range-property($prop))} </var>
</binding>) union $Binding
else 
<binding result="fail"/>
else 
if ((swrle:asignment($Binding,$Atom/swrl:argument2/@rdf:resource)=string(swrle:range-property($prop))) and  (swrle:asignment($Binding,$Atom/swrl:argument1/@rdf:resource)=string(swrle:domain-property($prop)))) then $Binding
else <binding result="fail"/>
};

declare function swrle:evaluate-atom($doc as node()*,$pos as xs:integer,$Atom as node()*,$Binding as node()*)
{
if ($Atom/../swrl:DifferentIndividualsAtom) then
swrle:DifferentIndividualsAtom($doc,$pos,$Atom,$Binding)
else
if ($Atom/../swrl:SameIndividualAtom) then 
swrle:SameIndividualAtom($doc,$pos,$Atom,$Binding)
else 
if ($Atom/swrl:propertyPredicate) 
then swrle:propertyPredicate($doc,$pos,$Atom,$Binding)
else if ($Atom/swrl:classPredicate)
then swrle:classPredicate($doc,$pos,$Atom,$Binding)
else
if ($Atom/swrl:builtin)
then  swrle:builtin($doc,$pos,$Atom,$Binding) 
else <binding result="fail"/>
};

 
declare function swrle:evaluate-body($Classes as node()*,$Properties as node()*,$Body as node()*,$Binding as node()*)
{
let $prop := 
if ($Body/swrl:AtomList/rdf:first/swrl:IndividualPropertyAtom/swrl:propertyPredicate) then 
$Properties/*[string(node-name(.))=
swrle:substring-after-namespace(($Body/swrl:AtomList/rdf:first/swrl:IndividualPropertyAtom/swrl:propertyPredicate/@rdf:resource),'#')]/..
else
if ($Body/swrl:AtomList/rdf:first/swrl:DatavaluedPropertyAtom/swrl:propertyPredicate) then 
$Properties/*[string(node-name(.))=
swrle:substring-after-namespace(($Body/swrl:AtomList/rdf:first/swrl:DatavaluedPropertyAtom/swrl:propertyPredicate/@rdf:resource),'#')]/..
else 
if ($Body/swrl:AtomList/rdf:first/swrl:ClassAtom/swrl:classPredicate) then
$Classes[some $type in rdf:type/@rdf:resource satisfies swrle:substring-after-namespace($type,'#')=
swrle:substring-after-namespace(($Body/swrl:AtomList/rdf:first/swrl:ClassAtom/swrl:classPredicate/@rdf:resource),'#')]
else 
if ($Body/swrl:AtomList/rdf:first/swrl:SameIndividualAtom) then
$Properties/*[string(node-name(.))="owl:sameAs"]/..
else 
if ($Body/swrl:AtomList/rdf:first/swrl:DifferentIndividualsAtom) then 
$Properties/*[string(node-name(.))="owl:differentFrom"]/..
else <builtin></builtin> return (: 1 :)
for $pos in 1 to count($prop) 
let $BindingHead := 
if ($Body/swrl:AtomList/rdf:first/swrl:IndividualPropertyAtom/swrl:propertyPredicate) 
then
swrle:evaluate-atom(
$prop,$pos,
$Body/swrl:AtomList/rdf:first/*,$Binding) 
else
if ($Body/swrl:AtomList/rdf:first/swrl:DatavaluedPropertyAtom/swrl:propertyPredicate) 
then
swrle:evaluate-atom($prop,$pos,
$Body/swrl:AtomList/rdf:first/*,$Binding) 
else
if ($Body/swrl:AtomList/rdf:first/swrl:ClassAtom/swrl:classPredicate) 
then 
swrle:evaluate-atom($prop,$pos,$Body/swrl:AtomList/rdf:first/*,$Binding)
else 
if ($Body/swrl:AtomList/rdf:first/swrl:SameIndividualAtom) 
then
swrle:evaluate-atom($prop,$pos,$Body/swrl:AtomList/rdf:first/*,$Binding)
else 
if ($Body/swrl:AtomList/rdf:first/swrl:DifferentIndividualsAtom) then 
swrle:evaluate-atom($prop,$pos,$Body/swrl:AtomList/rdf:first/*,$Binding)
else 
swrle:evaluate-atom($prop,$pos,$Body/swrl:AtomList/rdf:first/*,$Binding)
return    
if ($BindingHead/@result="fail") then ()
else
(
if ($Body/swrl:AtomList/rdf:rest/@rdf:resource="http://www.w3.org/1999/02/22-rdf-syntax-ns#nil") then
<value> {$BindingHead} </value>
else swrle:evaluate-body($Classes,$Properties,$Body/swrl:AtomList/rdf:rest,$BindingHead)
)
};   


declare function swrle:evaluate-rule($Classes as node()*,$Properties as node()*,$Body as node()*,$Head as node()*){
for $case in 
swrle:evaluate-body($Classes,$Properties,$Body,()) 
return
swrle:evaluate-head($Head,$case) 
};

declare function swrle:evaluate($Classes as node()*,$Properties as node()*,$Imp as node()){
for $Head in $Imp/swrl:head/swrl:AtomList return swrle:evaluate-rule($Classes,$Properties,$Imp/swrl:body,$Head)
};

declare function swrle:oneIndividual($ABox as node()*,$name as xs:string){
$ABox[@rdf:about=$name]
};


(: MAIN :)

declare function swrle:swrl($ABox as node()*,$rules as node()*){
let $Classes := swrle:ClassesThing($ABox) return
let $Properties := swrle:PropertiesThing($ABox) return
<result>
{
for $Imp in $rules//swrl:Imp  
return <rule> { swrle:evaluate($Classes,$Properties,$Imp) } </rule>
}
</result>
};