#define rand	pan_rand
#define pthread_equal(a,b)	((a)==(b))
#if defined(HAS_CODE) && defined(VERBOSE)
	#ifdef BFS_PAR
		bfs_printf("Pr: %d Tr: %d\n", II, t->forw);
	#else
		cpu_printf("Pr: %d Tr: %d\n", II, t->forw);
	#endif
#endif
	switch (t->forw) {
	default: Uerror("bad forward move");
	case 0:	/* if without executable clauses */
		continue;
	case 1: /* generic 'goto' or 'skip' */
		IfNotBlocked
		_m = 3; goto P999;
	case 2: /* generic 'else' */
		IfNotBlocked
		if (trpt->o_pm&1) continue;
		_m = 3; goto P999;

		 /* CLAIM liveness */
	case 3: // STATE 1 - _spin_nvr.tmp:4 - [(!((vm_running==0)))] (0:0:0 - 1)
		
#if defined(VERI) && !defined(NP)
#if NCLAIMS>1
		{	static int reported1 = 0;
			if (verbose && !reported1)
			{	int nn = (int) ((Pclaim *)pptr(0))->_n;
				printf("depth %ld: Claim %s (%d), state %d (line %d)\n",
					depth, procname[spin_c_typ[nn]], nn, (int) ((Pclaim *)pptr(0))->_p, src_claim[ (int) ((Pclaim *)pptr(0))->_p ]);
				reported1 = 1;
				fflush(stdout);
		}	}
#else
		{	static int reported1 = 0;
			if (verbose && !reported1)
			{	printf("depth %d: Claim, state %d (line %d)\n",
					(int) depth, (int) ((Pclaim *)pptr(0))->_p, src_claim[ (int) ((Pclaim *)pptr(0))->_p ]);
				reported1 = 1;
				fflush(stdout);
		}	}
#endif
#endif
		reached[2][1] = 1;
		if (!( !((((int)now.vm_running)==0))))
			continue;
		_m = 3; goto P999; /* 0 */
	case 4: // STATE 6 - _spin_nvr.tmp:6 - [-end-] (0:0:0 - 1)
		
#if defined(VERI) && !defined(NP)
#if NCLAIMS>1
		{	static int reported6 = 0;
			if (verbose && !reported6)
			{	int nn = (int) ((Pclaim *)pptr(0))->_n;
				printf("depth %ld: Claim %s (%d), state %d (line %d)\n",
					depth, procname[spin_c_typ[nn]], nn, (int) ((Pclaim *)pptr(0))->_p, src_claim[ (int) ((Pclaim *)pptr(0))->_p ]);
				reported6 = 1;
				fflush(stdout);
		}	}
#else
		{	static int reported6 = 0;
			if (verbose && !reported6)
			{	printf("depth %d: Claim, state %d (line %d)\n",
					(int) depth, (int) ((Pclaim *)pptr(0))->_p, src_claim[ (int) ((Pclaim *)pptr(0))->_p ]);
				reported6 = 1;
				fflush(stdout);
		}	}
#endif
#endif
		reached[2][6] = 1;
		if (!delproc(1, II)) continue;
		_m = 3; goto P999; /* 0 */

		 /* PROC :init: */
	case 5: // STATE 1 - vcpu_rolling_state.pml:87 - [pcode[0].enc_opcode = 2] (0:0:1 - 1)
		IfNotBlocked
		reached[1][1] = 1;
		(trpt+1)->bup.oval = ((int)now.pcode[0].enc_opcode);
		now.pcode[0].enc_opcode = 2;
#ifdef VAR_RANGES
		logval("pcode[0].enc_opcode", ((int)now.pcode[0].enc_opcode));
#endif
		;
		_m = 3; goto P999; /* 0 */
	case 6: // STATE 2 - vcpu_rolling_state.pml:87 - [pcode[0].enc_operand = 5] (0:0:1 - 1)
		IfNotBlocked
		reached[1][2] = 1;
		(trpt+1)->bup.oval = ((int)now.pcode[0].enc_operand);
		now.pcode[0].enc_operand = 5;
#ifdef VAR_RANGES
		logval("pcode[0].enc_operand", ((int)now.pcode[0].enc_operand));
#endif
		;
		_m = 3; goto P999; /* 0 */
	case 7: // STATE 3 - vcpu_rolling_state.pml:88 - [pcode[1].enc_opcode = 9] (0:0:1 - 1)
		IfNotBlocked
		reached[1][3] = 1;
		(trpt+1)->bup.oval = ((int)now.pcode[1].enc_opcode);
		now.pcode[1].enc_opcode = 9;
#ifdef VAR_RANGES
		logval("pcode[1].enc_opcode", ((int)now.pcode[1].enc_opcode));
#endif
		;
		_m = 3; goto P999; /* 0 */
	case 8: // STATE 4 - vcpu_rolling_state.pml:88 - [pcode[1].enc_operand = 3] (0:0:1 - 1)
		IfNotBlocked
		reached[1][4] = 1;
		(trpt+1)->bup.oval = ((int)now.pcode[1].enc_operand);
		now.pcode[1].enc_operand = 3;
#ifdef VAR_RANGES
		logval("pcode[1].enc_operand", ((int)now.pcode[1].enc_operand));
#endif
		;
		_m = 3; goto P999; /* 0 */
	case 9: // STATE 5 - vcpu_rolling_state.pml:89 - [pcode[2].enc_opcode = 1] (0:0:1 - 1)
		IfNotBlocked
		reached[1][5] = 1;
		(trpt+1)->bup.oval = ((int)now.pcode[2].enc_opcode);
		now.pcode[2].enc_opcode = 1;
#ifdef VAR_RANGES
		logval("pcode[2].enc_opcode", ((int)now.pcode[2].enc_opcode));
#endif
		;
		_m = 3; goto P999; /* 0 */
	case 10: // STATE 6 - vcpu_rolling_state.pml:89 - [pcode[2].enc_operand = 0] (0:0:1 - 1)
		IfNotBlocked
		reached[1][6] = 1;
		(trpt+1)->bup.oval = ((int)now.pcode[2].enc_operand);
		now.pcode[2].enc_operand = 0;
#ifdef VAR_RANGES
		logval("pcode[2].enc_operand", ((int)now.pcode[2].enc_operand));
#endif
		;
		_m = 3; goto P999; /* 0 */
	case 11: // STATE 7 - vcpu_rolling_state.pml:90 - [pcode[3].enc_opcode = 14] (0:0:1 - 1)
		IfNotBlocked
		reached[1][7] = 1;
		(trpt+1)->bup.oval = ((int)now.pcode[3].enc_opcode);
		now.pcode[3].enc_opcode = 14;
#ifdef VAR_RANGES
		logval("pcode[3].enc_opcode", ((int)now.pcode[3].enc_opcode));
#endif
		;
		_m = 3; goto P999; /* 0 */
	case 12: // STATE 8 - vcpu_rolling_state.pml:90 - [pcode[3].enc_operand = 0] (0:0:1 - 1)
		IfNotBlocked
		reached[1][8] = 1;
		(trpt+1)->bup.oval = ((int)now.pcode[3].enc_operand);
		now.pcode[3].enc_operand = 0;
#ifdef VAR_RANGES
		logval("pcode[3].enc_operand", ((int)now.pcode[3].enc_operand));
#endif
		;
		_m = 3; goto P999; /* 0 */
	case 13: // STATE 9 - vcpu_rolling_state.pml:92 - [(run RollingVCPU())] (0:0:0 - 1)
		IfNotBlocked
		reached[1][9] = 1;
		if (!(addproc(II, 1, 0)))
			continue;
		_m = 3; goto P999; /* 0 */
	case 14: // STATE 10 - vcpu_rolling_state.pml:93 - [-end-] (0:0:0 - 1)
		IfNotBlocked
		reached[1][10] = 1;
		if (!delproc(1, II)) continue;
		_m = 3; goto P999; /* 0 */

		 /* PROC RollingVCPU */
	case 15: // STATE 1 - vcpu_rolling_state.pml:64 - [((vm_running&&(step_count<8)))] (0:0:0 - 1)
		IfNotBlocked
		reached[0][1] = 1;
		if (!((((int)now.vm_running)&&(((int)now.step_count)<8))))
			continue;
		_m = 3; goto P999; /* 0 */
	case 16: // STATE 2 - vcpu_rolling_state.pml:68 - [raw_op = ((pcode[vip].enc_opcode^vkey)%4)] (0:5:2 - 1)
		IfNotBlocked
		reached[0][2] = 1;
		(trpt+1)->bup.ovals = grab_ints(2);
		(trpt+1)->bup.ovals[0] = ((int)((P0 *)_this)->_2_1_raw_op);
		((P0 *)_this)->_2_1_raw_op = ((((int)now.pcode[ Index(((int)now.vip), 8) ].enc_opcode)^((int)now.vkey))%4);
#ifdef VAR_RANGES
		logval("RollingVCPU:raw_op", ((int)((P0 *)_this)->_2_1_raw_op));
#endif
		;
		/* merge: handler_id = raw_op(5, 3, 5) */
		reached[0][3] = 1;
		(trpt+1)->bup.ovals[1] = ((int)now.handler_id);
		now.handler_id = ((int)((P0 *)_this)->_2_1_raw_op);
#ifdef VAR_RANGES
		logval("handler_id", ((int)now.handler_id));
#endif
		;
		_m = 3; goto P999; /* 1 */
	case 17: // STATE 4 - vcpu_rolling_state.pml:42 - [vkey = ((((vkey*3)+handler_id)+5)%16)] (0:0:1 - 1)
		IfNotBlocked
		reached[0][4] = 1;
		(trpt+1)->bup.oval = ((int)now.vkey);
		now.vkey = ((((((int)now.vkey)*3)+((int)now.handler_id))+5)%16);
#ifdef VAR_RANGES
		logval("vkey", ((int)now.vkey));
#endif
		;
		_m = 3; goto P999; /* 0 */
	case 18: // STATE 6 - vcpu_rolling_state.pml:48 - [((handler_id==0))] (25:0:4 - 1)
		IfNotBlocked
		reached[0][6] = 1;
		if (!((((int)now.handler_id)==0)))
			continue;
		/* merge: vsp = ((vsp-1)%16)(25, 7, 25) */
		reached[0][7] = 1;
		(trpt+1)->bup.ovals = grab_ints(4);
		(trpt+1)->bup.ovals[0] = ((int)now.vsp);
		now.vsp = ((((int)now.vsp)-1)%16);
#ifdef VAR_RANGES
		logval("vsp", ((int)now.vsp));
#endif
		;
		/* merge: vstack[vsp] = ((pcode[vip].enc_operand^vkey)%16)(25, 8, 25) */
		reached[0][8] = 1;
		(trpt+1)->bup.ovals[1] = ((int)now.vstack[ Index(((int)now.vsp), 16) ]);
		now.vstack[ Index(now.vsp, 16) ] = ((((int)now.pcode[ Index(((int)now.vip), 8) ].enc_operand)^((int)now.vkey))%16);
#ifdef VAR_RANGES
		logval("vstack[vsp]", ((int)now.vstack[ Index(((int)now.vsp), 16) ]));
#endif
		;
		/* merge: .(goto)(25, 18, 25) */
		reached[0][18] = 1;
		;
		/* merge: vip = ((vip+1)%8)(25, 20, 25) */
		reached[0][20] = 1;
		(trpt+1)->bup.ovals[2] = ((int)now.vip);
		now.vip = ((((int)now.vip)+1)%8);
#ifdef VAR_RANGES
		logval("vip", ((int)now.vip));
#endif
		;
		/* merge: step_count = (step_count+1)(25, 21, 25) */
		reached[0][21] = 1;
		(trpt+1)->bup.ovals[3] = ((int)now.step_count);
		now.step_count = (((int)now.step_count)+1);
#ifdef VAR_RANGES
		logval("step_count", ((int)now.step_count));
#endif
		;
		/* merge: .(goto)(0, 26, 25) */
		reached[0][26] = 1;
		;
		_m = 3; goto P999; /* 6 */
	case 19: // STATE 9 - vcpu_rolling_state.pml:51 - [((handler_id==1))] (25:0:4 - 1)
		IfNotBlocked
		reached[0][9] = 1;
		if (!((((int)now.handler_id)==1)))
			continue;
		/* merge: vstack[(vsp+1)] = ((vstack[vsp]+vstack[(vsp+1)])%16)(25, 10, 25) */
		reached[0][10] = 1;
		(trpt+1)->bup.ovals = grab_ints(4);
		(trpt+1)->bup.ovals[0] = ((int)now.vstack[ Index((((int)now.vsp)+1), 16) ]);
		now.vstack[ Index((now.vsp+1), 16) ] = ((((int)now.vstack[ Index(((int)now.vsp), 16) ])+((int)now.vstack[ Index((((int)now.vsp)+1), 16) ]))%16);
#ifdef VAR_RANGES
		logval("vstack[(vsp+1)]", ((int)now.vstack[ Index((((int)now.vsp)+1), 16) ]));
#endif
		;
		/* merge: vsp = ((vsp+1)%16)(25, 11, 25) */
		reached[0][11] = 1;
		(trpt+1)->bup.ovals[1] = ((int)now.vsp);
		now.vsp = ((((int)now.vsp)+1)%16);
#ifdef VAR_RANGES
		logval("vsp", ((int)now.vsp));
#endif
		;
		/* merge: .(goto)(25, 18, 25) */
		reached[0][18] = 1;
		;
		/* merge: vip = ((vip+1)%8)(25, 20, 25) */
		reached[0][20] = 1;
		(trpt+1)->bup.ovals[2] = ((int)now.vip);
		now.vip = ((((int)now.vip)+1)%8);
#ifdef VAR_RANGES
		logval("vip", ((int)now.vip));
#endif
		;
		/* merge: step_count = (step_count+1)(25, 21, 25) */
		reached[0][21] = 1;
		(trpt+1)->bup.ovals[3] = ((int)now.step_count);
		now.step_count = (((int)now.step_count)+1);
#ifdef VAR_RANGES
		logval("step_count", ((int)now.step_count));
#endif
		;
		/* merge: .(goto)(0, 26, 25) */
		reached[0][26] = 1;
		;
		_m = 3; goto P999; /* 6 */
	case 20: // STATE 12 - vcpu_rolling_state.pml:54 - [((handler_id==2))] (25:0:4 - 1)
		IfNotBlocked
		reached[0][12] = 1;
		if (!((((int)now.handler_id)==2)))
			continue;
		/* merge: vstack[(vsp+1)] = (~((vstack[vsp]|vstack[(vsp+1)]))%16)(25, 13, 25) */
		reached[0][13] = 1;
		(trpt+1)->bup.ovals = grab_ints(4);
		(trpt+1)->bup.ovals[0] = ((int)now.vstack[ Index((((int)now.vsp)+1), 16) ]);
		now.vstack[ Index((now.vsp+1), 16) ] = ( ~((((int)now.vstack[ Index(((int)now.vsp), 16) ])|((int)now.vstack[ Index((((int)now.vsp)+1), 16) ])))%16);
#ifdef VAR_RANGES
		logval("vstack[(vsp+1)]", ((int)now.vstack[ Index((((int)now.vsp)+1), 16) ]));
#endif
		;
		/* merge: vsp = ((vsp+1)%16)(25, 14, 25) */
		reached[0][14] = 1;
		(trpt+1)->bup.ovals[1] = ((int)now.vsp);
		now.vsp = ((((int)now.vsp)+1)%16);
#ifdef VAR_RANGES
		logval("vsp", ((int)now.vsp));
#endif
		;
		/* merge: .(goto)(25, 18, 25) */
		reached[0][18] = 1;
		;
		/* merge: vip = ((vip+1)%8)(25, 20, 25) */
		reached[0][20] = 1;
		(trpt+1)->bup.ovals[2] = ((int)now.vip);
		now.vip = ((((int)now.vip)+1)%8);
#ifdef VAR_RANGES
		logval("vip", ((int)now.vip));
#endif
		;
		/* merge: step_count = (step_count+1)(25, 21, 25) */
		reached[0][21] = 1;
		(trpt+1)->bup.ovals[3] = ((int)now.step_count);
		now.step_count = (((int)now.step_count)+1);
#ifdef VAR_RANGES
		logval("step_count", ((int)now.step_count));
#endif
		;
		/* merge: .(goto)(0, 26, 25) */
		reached[0][26] = 1;
		;
		_m = 3; goto P999; /* 6 */
	case 21: // STATE 15 - vcpu_rolling_state.pml:57 - [((handler_id==3))] (25:0:3 - 1)
		IfNotBlocked
		reached[0][15] = 1;
		if (!((((int)now.handler_id)==3)))
			continue;
		/* merge: vm_running = 0(25, 16, 25) */
		reached[0][16] = 1;
		(trpt+1)->bup.ovals = grab_ints(3);
		(trpt+1)->bup.ovals[0] = ((int)now.vm_running);
		now.vm_running = 0;
#ifdef VAR_RANGES
		logval("vm_running", ((int)now.vm_running));
#endif
		;
		/* merge: .(goto)(25, 18, 25) */
		reached[0][18] = 1;
		;
		/* merge: vip = ((vip+1)%8)(25, 20, 25) */
		reached[0][20] = 1;
		(trpt+1)->bup.ovals[1] = ((int)now.vip);
		now.vip = ((((int)now.vip)+1)%8);
#ifdef VAR_RANGES
		logval("vip", ((int)now.vip));
#endif
		;
		/* merge: step_count = (step_count+1)(25, 21, 25) */
		reached[0][21] = 1;
		(trpt+1)->bup.ovals[2] = ((int)now.step_count);
		now.step_count = (((int)now.step_count)+1);
#ifdef VAR_RANGES
		logval("step_count", ((int)now.step_count));
#endif
		;
		/* merge: .(goto)(0, 26, 25) */
		reached[0][26] = 1;
		;
		_m = 3; goto P999; /* 5 */
	case 22: // STATE 20 - vcpu_rolling_state.pml:77 - [vip = ((vip+1)%8)] (0:25:2 - 5)
		IfNotBlocked
		reached[0][20] = 1;
		(trpt+1)->bup.ovals = grab_ints(2);
		(trpt+1)->bup.ovals[0] = ((int)now.vip);
		now.vip = ((((int)now.vip)+1)%8);
#ifdef VAR_RANGES
		logval("vip", ((int)now.vip));
#endif
		;
		/* merge: step_count = (step_count+1)(25, 21, 25) */
		reached[0][21] = 1;
		(trpt+1)->bup.ovals[1] = ((int)now.step_count);
		now.step_count = (((int)now.step_count)+1);
#ifdef VAR_RANGES
		logval("step_count", ((int)now.step_count));
#endif
		;
		/* merge: .(goto)(0, 26, 25) */
		reached[0][26] = 1;
		;
		_m = 3; goto P999; /* 2 */
	case 23: // STATE 23 - vcpu_rolling_state.pml:80 - [((!(vm_running)||(step_count>=8)))] (0:0:0 - 1)
		IfNotBlocked
		reached[0][23] = 1;
		if (!(( !(((int)now.vm_running))||(((int)now.step_count)>=8))))
			continue;
		_m = 3; goto P999; /* 0 */
	case 24: // STATE 28 - vcpu_rolling_state.pml:83 - [-end-] (0:0:0 - 3)
		IfNotBlocked
		reached[0][28] = 1;
		if (!delproc(1, II)) continue;
		_m = 3; goto P999; /* 0 */
	case  _T5:	/* np_ */
		if (!((!(trpt->o_pm&4) && !(trpt->tau&128))))
			continue;
		/* else fall through */
	case  _T2:	/* true */
		_m = 3; goto P999;
#undef rand
	}

