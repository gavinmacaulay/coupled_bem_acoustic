#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function bem_run_fluid_farfield(K0::Real, K1::Real, rho0::Real, rho1::Real, pext::Array, angles::Array,
    meshFilename::String, resultsFilename::String, cores::Array)

    println("Loading mesh.")
    normales1, selv1, vertex1 = GetMesh_fast( meshFilename );
    # these meshes have units of millimetres, but the simulations need metres
    vertex1 = vertex1 * 1e-3;

    println("Sending data to cores.")
    for i in cores
        SendToProc( i, selv1 = selv1, vertex1 = vertex1, normales1 = normales1);
        SendToProc( i, K0 = K0, K1 = K1, Pext = Pext, rho0 = rho0, rho1 = rho1);
    end

    println("Calculating backscatter.")
    finf = bem_fluid_farfield_bs(K0, K1, rho0, rho1, Pext, selv1, vertex1, normales1, 
        cores, ComplexF64)

    println("Saving results.")
    writedlm( resultsFilename, [ angles  TS.( finf ) ] ) ;

    @everywhere GC.gc();

end
