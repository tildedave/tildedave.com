---
layout: post
title: 'Programming Sins'
is_unlisted: 1

---

Often in many writings on the internet, you see the notion that all we need to do to teach computer science is to follow some awesome true method.  Sometimes (often) this is [C](http://www.reddit.com/r/programming/comments/gxkus/cruelty_redefined_undergraduates_vs_c_on_linux/), sometimes this is some wonderful platonic world of [functional programming](http://existentialtype.wordpress.com/2011/03/16/what-is-a-functional-language/).

I firmly believe that in order to be a good programmer you need to have been a really awful programmer first.  However, you need to be a special kind of awful programmer:

* don't listen to anyone
* don't try to figure out why something was done the first time
* don't write any tests
* don't ever clean anything up, ever (putting `// TODO: refactor` comments everywhere gives extra demerits)
* just get it working and then ship it

Once you have done everything wrong, then the real learning can begin.  This is where the benefits of a classical computer science education stand out: you have learned essentially the full stack of the computer, the whys and traceoffs of each level -- at least, in theory (don't ask me to calculate how a cache lookup happens in an M-bit N-size L2 cache).

I've written a lot of code that I'm not proud of that got me to where I am today.  Luckily my thesis code is a special brand of awful that makes it an eternal spring of crappiness to revisit over and over again.

If I was to be punished for my programming sins, the list of offenses would definitely include:

<i>(Not a comprehensive list)</i>

## Way too many data structures

```java
protected Map<JLiftVarLabel, Node> variableToNodeMap;

protected MultiMap<JLiftVarLabel, JLiftVarLabel> directVariableAffectMap;
protected MultiMap<JLiftVarLabel, JLiftVarLabel> directVariableAffectingMap;

protected MultiMap<Node, Label> specialSinks;
protected Map<Node, JLiftVarLabel> nodeToVariableMap;

protected Map<JLiftVarLabel, Collection<JLiftVarLabel>> cacheVarLabelAffectMap;
protected Map<JLiftVarLabel, Collection<JLiftVarLabel>> cacheVarLabelAffectingMap;

protected Map<Node, Collection<Node>> cacheNodeAffectMap;
protected Map<Node, Collection<Node>> cacheNodeAffectingMap;

protected DFSGraph<JLiftVarLabel> varGraph;
protected DFSGraph<JLiftVarLabel> mirrorVarGraph;
protected CacheCallBack<JLiftVarLabel> callBackObject;

protected Map<JLiftVarLabel, Label> lvarMap;

private final Map<JLiftVarLabel, JLiftLabelConstraint> variableToConstraintMap;
```

I'm sure there's some reason that the class needed 14 private members, but I can't remember it any more!

## Lots of commented out code

```java
/*
private boolean isSinkConstraint(LabelConstraint c) {
    return containsPairLabel(getSinkLabelForConstraint(c));
}

private boolean isSourceConstraint(LabelConstraint c) {
    return containsPairLabel(getSourceLabelForConstraint(c));
}


private Label getSinkLabelForConstraint(LabelConstraint c) {
    // tau <= c <<-  c is the sink
    // v == tau <<-  tau is the sink
    if (c.kind() == LabelConstraint.LEQ || c.kind() == LabelConstraint.EQUAL)
        return c.rhs();
    // v ==_{def} tau ||--> tau <= v <<-- v is the sink (a define should not be a sink)
    else if (c.kind() == LabelConstraint.DEFINE)
        return c.lhs();

    return null;
}

private Label getSourceLabelForConstraint(LabelConstraint c) {
    // v == tau <<-  tau is the source
    if (c.kind() == LabelConstraint.EQUAL)  {
        return c.rhs();
    }
    // tau <= v <<-  tau is the source
    if (c.kind() == LabelConstraint.LEQ)
        return c.lhs();
    // v ==_{def} tau ||--> tau <= v <<-- tau is the source
    if (c.kind() == LabelConstraint.DEFINE)
        return c.rhs();

    return null;
}

private boolean foundPairLabel;

private boolean containsPairLabel(Label lhs) {
    foundPairLabel = false;

    LabelSubstitution ls = new LabelSubstitution() {
            @Override
                public Label substLabel(Label L) throws SemanticException {
                if (L instanceof PairLabel) {
                    foundPairLabel = true;
                }
                return L;
            }
        };

    try {
        lhs.subst(ls);
    } catch (SemanticException e) {
        throw new InternalCompilerError(e);
    }

    return foundPairLabel;
}
*/
```

But I might need it later! (and I probably did at some point, commenting and uncommenting things until they worked again)

## What the hell are you trying to do?

```java
public JLiftCallHelper(Label receiverLabel,
                       Receiver receiver,
                       ReferenceType calleeContainer,
                       JifProcedureInstance pi,
                       List actualArgs,
                       Position position) {
    super(receiverLabel, receiver, calleeContainer, pi, actualArgs, position);
    this.receiverLabel = receiverLabel;
    this.calleeContainer = calleeContainer;
    if (receiver instanceof Expr) {
        this.receiverExpr = (Expr)receiver;
    }
    else {
        this.receiverExpr = null;
    }
    this.actualArgs = new ArrayList(actualArgs);
    this.pi = pi;
    this.position = position;
    this.callChecked = false;

    if (pi.formalTypes().size() != actualArgs.size())
        throw new InternalCompilerError("Wrong number of args.");
}
```

Demerits:

* Throwing an exception from a constructor
* Incomprehensible choice of constructor arguments
* `instanceof` check
* setting something to `null` if the `instanceof` check fails
* boolean flag initialized to `false` on object creation (explicit state!  agh!)
* recasting a `List` into an `ArrayList` (I guess I wanted to use this as a vector, despite it starting with no structure?)
* raw Java pre-1.5 types (`ArrayList` and `List` instead of `ArrayList<>` and `List<>`)
</ul>

Really this is awful code and it's doing less than any of the other snippets here (including the commented block).

At least the method signature problems were inherited from the superclass.

## Copy and Pasted Code

```java
public class JLiftConstructorDecl_c extends JifConstructorDecl_c {

	@Override
	public Node typeCheck(TypeChecker tc) throws SemanticException {
		if (!((JLiftTypeSystem) tc.typeSystem()).allowSmallLeaks())
			return super.typeCheck(tc);
		else {
			// HACK: copy/pasted from ConstructorDecl_c
			Context c = tc.context();
			TypeSystem ts = tc.typeSystem();

			ClassType ct = c.currentClass();
```

For this one I at least had an excuse.  C extends B extends A; all of them implement `foo`.  Sometimes we want C to call A's `foo`, sometimes we want to call B's `foo`.  Unfortunately, Java's inheritance model doesn't support that. Solution: copy and paste some code!

## Method That's Way Way Way Too Long

```ocaml
let constraint_set_to_flowgraph cl lattice =
  match cl with
    | [] -> G.create ()
    | _  ->
      let atoms = timeThunk (fun _ -> atoms_in_conslist cl) (SimpTimer.record_time "get atoms in constaint list") in
      let _ =
	begin
	  Printf.printf ("%d atoms\n") (LexpSet.cardinal atoms);
	  flush stdout
	end
      in
      let g = G.create ~size:(LexpSet.cardinal atoms) () in
      let get_sub_lv_node s lexp =
	match lexp with
	  | (LVar (lv,t)) -> LVar (lv,s :: t)
	  | _ -> raise (Failure "cannot get sub lv node for non-lvar")
      in
      let get_incoming_lv_node = get_sub_lv_node `Incoming and
	  get_outgoing_lv_node = get_sub_lv_node `Outgoing in
      let get_incoming_node a =
	match a with
	  | LVar (ExpLVar l,t) -> get_incoming_lv_node a
	  | _ -> a
      and
	  get_outgoing_node a =
	match a with
	  | LVar (ExpLVar l,t) -> get_outgoing_lv_node a
	  | _ -> a
      in
      begin
	timeThunk
	  (fun _ ->
	    LexpSet.iter
	      (function
		| LVar (l,t) ->
		  (match l with
		    | ExpLVar e ->
		      let incoming_l = get_incoming_lv_node (LVar (l,t)) and
			  outgoing_l = get_outgoing_lv_node (LVar (l,t)) in
		      let nodeId = id_for_lexp incoming_l in
		      let incoming_tag = GraphLabel.tagForNode incoming_l and
			  outgoing_tag = GraphLabel.tagForNode outgoing_l in
		      begin
				      (*Printf.printf ("incoming: %d, outgoing: %d\n") incoming_tag outgoing_tag;*)
			timeThunk (fun _ -> (G.add_vertex g incoming_tag;
					     G.add_vertex g outgoing_tag))
			  (SimpTimer.record_time ~silent:true "graph building (add_vertex)");
			let edgeWeight = match nodeId with
			  | Some id ->
			    if (StringSet.mem id (!XmlConstraintReader.nvNoDeclassify)) then
			      infinity_hack
			    else
			      (match (weight_for_lexp (LVar (l,t))) with
				| None -> 1
				| Some n -> n)
			  | None -> 1
			in
			G.add_edge_e g (G.E.create incoming_tag edgeWeight outgoing_tag);
					  (*Printf.printf("\tadded vertices to graph\n");
					    flush stdout;*) ()
		      end
		    | _ ->
		      let lvar_tag = GraphLabel.tagForNode (LVar (l,t))
		      in
		      begin
			timeThunk (fun _ -> G.add_vertex g lvar_tag) ((SimpTimer.record_time ~silent:true "graph building (add_vertex)"));
				      (*Printf.printf ("added tag for %s\n") (lexp_to_string (LVar (l,t)));
				        flush stdout;*) ()
		      end
		  )
		| Label n ->
		  let lab_tag = GraphLabel.tagForNode (Label n)
		  in
		  G.add_vertex g lab_tag
		| Join (_,_) -> raise (Failure "graph contains non-atomic node"))
	      atoms)
	  (SimpTimer.record_time "building graph (add nodes)");
	Printf.printf ("added each atom to the graph as a node -- graph size %d nodes\n") (G.nb_vertex g);
	flush stdout;
	timeThunk
	  (fun _ ->
	    List.iter
	      (fun (Leq (le,rhsA)) ->
			  (* add variable connections -- note that don't care if something flows to top or from bottom! *)
		let lhsAtoms = atoms_in_lexp le in
		LexpSet.iter
		  (fun a ->
		    let add_edge_thunk =
		      fun _ ->
			let e = G.E.create
			  (GraphLabel.tagForNode (get_outgoing_node a))
			  (infinity_hack)
			  (GraphLabel.tagForNode (get_incoming_node rhsA))
			in
				  (*Printf.printf ("edge: (%s,%s)\n\tconstraint: %s\n") (lexp_to_string a) (lexp_to_string rhsA) (cons_to_string (Leq (le,rhsA)));*)
			G.add_edge_e g e
		    in
		    match a with
		      | Label id -> if (LatticeGraph.is_bottom lattice id) then () else add_edge_thunk ()
		      | _ -> add_edge_thunk ())
		  lhsAtoms)
	      cl)
	  (SimpTimer.record_time "building graph (add edges)");
	Printf.printf ("added edges between each atom to the graph -- graph size %d vertices, %d edges\n") (G.nb_vertex g) (G.nb_edges g);
	flush stdout;
	g
      end
```

I have no idea what this function is doing either.

## No Unit Tests

Nothing here because I didn't write anything!

(I did end up with several integration-level tests that were essentially glued-together bash scripts but that will not come to my rescue here)

## Being a Recovering Horrible Programmer

Well, I'd like to think the moral is that nobody's perfect and that everyone writes bad code and that if I had to do it all over again I'd be sure to fix all the sins that I've documented here, do it more cleanly, etc., etc., but that's a lie.

I had to get stuff done and I did it.  The code wasn't pretty but it worked well enough to generate publishable results.

However, all this bad code ended up being the best kind of teacher:

* I didn't realize how important modules and small classes were until I had classes that spanned hundreds of lines
* I didn't learn how important short methods were until I had to debug a bunch of long methods
* I didn't learn how important regression tests were until I changed something in the morning and had to spend the afternoon restoring my compiler
* I didn't realize how important distinct units of computation were until I spent about a month chasing down performance problems in my OCaml code.  (These problems were determined to either be in a library or my integration with the library.  I gave up and rewrote the OCaml code in C++ in about a week.)

Throughout all this I could never blame anyone except for myself.  I let the code get too big, too unwieldy, too impenetrable to change, and the programmer that I was always cleaning up after was me.

Lessons learned.  I regret nothing!  (except for not writing unit tests)
