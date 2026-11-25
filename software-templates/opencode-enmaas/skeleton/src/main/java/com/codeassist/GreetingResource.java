package com.codeassist;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import java.util.Map;

@Path("/api")
public class GreetingResource {

    @GET
    @Path("/hello")
    @Produces(MediaType.APPLICATION_JSON)
    public Map<String, String> hello() {
        return Map.of(
                "message", "Hello from the RHADS OpenCode / EnMaaS demo app",
                "hint", "Use OpenCode in Dev Spaces (EnMaaS + OpenShell) to evolve this service");
    }

    @GET
    @Path("/info")
    @Produces(MediaType.APPLICATION_JSON)
    public Map<String, String> info() {
        return Map.of(
                "stack", "quarkus",
                "inference", "enmaas-praxis",
                "sandbox", "openshell");
    }
}
