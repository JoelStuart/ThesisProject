package Collision;

import com.sun.corba.se.impl.orbutil.graph.Graph;
import sun.security.provider.certpath.Vertex;

import java.io.*;
import java.util.*;

public class Collision {
    String inFile;
    String outFile;
    double radius = 22;
    int numObjects;
    int numParticles;
    double invPart;
    Map<Pair, Integer> occurances = new HashMap<Pair, Integer>();
    Map<Pair, Pair> likelihood = new HashMap<Pair, Pair>();
    Set<Integer> close = new HashSet<>();


    public Collision(String[] args) {
        //Read in arguments

        inFile = args[0];
        outFile = args[1];
        readInput();
        exit(0);

    }

    private void readInput() {

        try {
            BufferedReader br = new BufferedReader(new FileReader(inFile));

            //Read in number of objects
            String line = br.readLine();
            numObjects = Integer.parseInt(line);
            //Read in number of particles
            line = br.readLine();
            numParticles = Integer.parseInt(line);
            invPart = 1.0/numParticles;
            System.out.print("Starting up...\n");

            //Read next line and initialise row counter
            line = br.readLine();
            //int timeStep = 1;
            //String delim = " ";
            while (line != null) {

                String[] tokens = line.split(" ");
                int tokenCount = tokens.length;
                if (tokenCount != 2){
                    System.out.print("Exiting file\n");
                    System.exit(1);

                }
                System.out.print("Timestep: " + tokens[1] + "...\n");


                parseTimeStep(br);



                line = br.readLine();

            }
        } catch (IOException e) {
            System.out.print(e);
        }
    }

    private void parseTimeStep(BufferedReader br) throws IOException{
        ArrayList<Map<Integer, Double[]>> timestep = new ArrayList<Map<Integer, Double[]>>();
        // array list<Map<Integer, Double[]>>>

        //HashSet<Double[]> timestep = new HashSet<Double[]>();
        String delim = " ";
        //Particles as well -> seperate into objects
        //int counter = 0;

        for (int obj = 0; obj < numObjects*numParticles;) {
            Map<Integer, Double[]> map = new HashMap<Integer, Double[]>();
            for (int i = 0; i < numParticles; i++){
                String line = br.readLine();
                if (line == null){
                    System.out.print("Error / end of file\n");
                    exit(2);
                }
                String[] tokens = line.split(delim);
                int tokenCount = tokens.length;
                if (tokenCount != 4){
                    System.out.print("Invalid timestep line\n");
                }
                Double[] object = {Double.parseDouble(tokens[1]), Double.parseDouble(tokens[2]), Double.parseDouble(tokens[3])};
                map.put(i, object);
            }
            timestep.add(map);
            obj += numParticles;

        }
        //Iterator I = timestep.iterator();
        Map<Integer, Double[]> currentI = new HashMap<>();
        Map<Integer, Double[]> currentJ = new HashMap<>();
        Collection<Double[]> set = new HashSet<Double[]>();
        Iterator I = set.iterator();
        int countI = 0;
        long start = System.currentTimeMillis();
        for(int i=0; i < numObjects*numParticles; i++) {
            int modI = i % numParticles;
            if (modI == 0){
                currentI = timestep.get(countI);
                countI += 1;
            }
            if (currentI == null){
                System.out.print("Map error\n");
            }
            int countJ = countI;
            //Iterator J = timestep.iterator();
            Double[] objectI = currentI.get(modI);
            for (int j = i + numParticles; j < (numObjects*numParticles)-1; j++) {
                int modJ = j % numParticles;
                if (modJ == 0){
                    currentJ = timestep.get(countJ);
                    //set = currentJ.values();
                    //I = set.iterator();
                    countJ += 1;
                }
                if (currentJ == null){
                    System.out.print("Map error\n");
                }
                //Double[] objectI = (Double[]) I.next();
                //Double[] objectJ = (Double[]) J.next();

                Double[] objectJ = currentJ.get(modJ);

                //Double[] objectJ = (Double[]) I.next();



                double dx = objectI[0] - objectJ[0];
                double dy = objectI[1] - objectJ[1];
                double dz = objectI[2] - objectJ[2];
                double dist = Math.sqrt((dx * dx) + (dy * dy) + (dz * dz));

                //If collision detected between objects (radius defined in header)
                if (dist < radius) {
                    //System.out.print("Close approach between " + i + " and " + j + "\n");
                    Pair pair = new Pair(i, j);
                    if (!occurances.containsKey(pair)){

                    }
                    //int occurance = occurances.getOrDefault(pair, 0);
                    //double calc = 1.0/numParticles;
                    //System.out.print(calc);
                    //occurance += 1;
                    occurances.put(pair, 1);


                }
            }

        }
        long time = System.currentTimeMillis() - start;
        //System.out.printf("Ts took %.1f ms%n", time / 1.0);


    }

    private void exit(int code){
        updateLikelihood();
        System.out.print("\nClose approach report:\n");
        System.out.print("(Probability refers to sum of (1/N) where N number of particles with close approach).\n\n");
        if (likelihood.size() == 0){
            System.out.print("No close approaches detected.\n");
        }
        for (Map.Entry<Pair, Pair> s : likelihood.entrySet()){
            //System.out.print("Close approach between objects " + s.getKey().first + " and " + s.getKey().second + " with probablity "
            //        + s.getValue().first + " with " + s.getValue().second + " occurances.\n");
            System.out.print("Close approach between objects " + s.getKey().first + " and " + s.getKey().second + " with probablity "
                            + (((double) close.size()) / (double) (numParticles*numObjects))+ "\n");
        }
        System.out.print("\nExiting...\n");
        System.exit(code);
    }

    private void updateLikelihood(){
        HashSet set = new HashSet();
        for (Map.Entry<Pair, Integer> s : occurances.entrySet()){
            int a = (int) s.getKey().first;
            int b = (int) s.getKey().second;

            int i = Math.floorDiv(a,numParticles);
            int j = Math.floorDiv(b,numParticles);
            Pair objs = new Pair(i,j);

           // Pair value = likelihood.getOrDefault(objs, new Pair(0.0, 0));

            /*
            int o = s.getValue();
            double p = (double) value.first;
            int occ = (int) value.second;

            if (!(set.contains(a) && set.contains(b))){
                p += invPart;
            }
            occ += o;
            value.first = p;
            value.second = occ;
            ;*/
            likelihood.putIfAbsent(objs, new Pair(0.0, 0));
            if (!close.contains(a)){
                close.add(a);
            }
            if (!close.contains(b)){
                close.add(b);
            }


            if (!set.contains(a)){
                set.add(a);
            }
            if (!set.contains(b)){
                set.add(b);
            }

        }
    }

    private void clearFile() {
        try {
            File file = new File(outFile);
            PrintWriter writer = new PrintWriter(file);
            writer.print("");
            writer.close();

        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static void main(String[] args) {
        Collision s = new Collision(args);
	// write your code here
    }
}
